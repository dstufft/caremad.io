---
title: Distributing a CFFI Project
date: 2014-11-16T10:38:00-05:00
---

[CFFI][] is a C Foreign Function Interface for Python. It sits somewhere
between writing a full blown C extension and using the ctypes interface. It is
a great way to call into C code from within Python with a few important
advantages over C extensions, ctypes, and SWIG:

[CFFI]: https://cffi.readthedocs.org/

* Operates at the API level not the ABI level (*ctypes*).
* Keeps all logic inside Python, allowing you to write as little non Python
  code as possible (*c extensions*).
* It simply calls C code from Python code, it does not require learning a
  DSL (*Cython*, *SWIG*) and it's API is very minimal (*ctypes*).
* Works sanely and with good performance in both PyPy and CPython and has a
  reasonable path for alternative implementations to support it as well.

I've used CFFI for awhile now, and I can easily say that I fully recommend it
for any one needing to call into C from Python. However CFFI does have one
particularly gnarly problem: Packaging.

Correctly and sanely distributing an application written using CFFI is an
exercise in frustration requiring a thorough understanding of the packaging
toolchain, CFFI, and Python itself. On top of that CFFI has a sort of
misfeature where it will implicitly compile the generated C extension if it
cannot load one. This is incredibly handy during iterative development but can
wreak havoc on your ability to test the installation of your project as if it
were being deployed.


## Minimal Example

Here is a minimal example of using CFFI to be able to call the ``printf``
function from Python:

```python
from cffi import FFI

ffi = FFI()
ffi.cdef(
    """
    int printf(const char *format, ...);
    """
)

c = ffi.verify(
    """
    #include <stdio.h>
    """
)


if __name__ == "__main__":
    c.printf(b"Hi There!\n")
```


This example works and if you save it into your current directory and execute
it with ``PYTHONPATH=. python -m example`` you'll get output that looks like:

```console
$ PYTHONPATH=. python -m example
Hi There!
```

This works because when you call the ``ffi.verify`` function CFFI will attempt
to load an already compiled module for this ``FFI`` instance, and failing to
find it will implicitly compile a new one and then load it. This particular
feature can be a great boon while iteratively developing a project because you
never have to explicitly compile anything. In effect it makes working on a C
binding as simple and quick as working on a pure Python project.


## Packaging our Example Project

Now that we have a simple ``example.py`` file we can package this up so that we
can distribute it to other people. We'll use a simple ``setup.py`` taken from
the CFFI docs with some slight modifications to fit our project:

```python
# The CFFI docs suggest that you can also use distutils, while technically
# correct you should use setuptools because otherwise you cannot specify
# a dependency on CFFI.
from setuptools import setup

# you must import at least the module(s) that define the ffi's
# that you use in your application
import example

setup(
    name="example",
    version="0.1",
    py_modules=["example"],
    ext_modules=[
        example.ffi.verifier.get_extension(),
    ],
    install_requires=[
        "cffi",
    ],
    zip_safe=False,
)
```

Now that we have our ``setup.py`` we can go ahead and create a sdist using the
command ``python setup.py sdist`` which will give us ``example-0.1.tar.gz`` in
the ``dist/`` folder. We can even publish it to PyPI and then let other users
install it using ``pip install example``!

Except they won't be able to install it because what we actually would have
published is a broken package that relies on:

1. The python development headers to be installed (If installing into CPython)
2. The libffi development headers to be installed (If installing into CPython)
3. CFFI (and dependencies) to be installed.

There isn't much that can be done about #1 or #2 they will just need to be
documented as required, however for #3 we can utilize a setuptools feature
called ``setup_requires`` in order to ensure that CFFI is installed when the
``setup.py`` is executed. Using this feature for CFFI is a little bit ugly
because the items inside of ``setup_requires`` will get installed as the first
part of executing the ``setup()`` function, however at that point it's already
too late because we need to be able to pass in the ``ext_modules`` into the
``setup()`` call. Luckily distutils/setuptools does provide the right kind of
hooks to make this possible.

Let's modify our ``setup.py`` and fix our lack of CFFI problem:

```python
from distutils.command.build import build
from setuptools import setup
from setuptools.command.install import install


def get_ext_modules():
    import example
    return [example.ffi.verifier.get_extension()]


class CFFIBuild(build):
    def finalize_options(self):
        self.distribution.ext_modules = get_ext_modules()
        build.finalize_options(self)


class CFFIInstall(install):
    def finalize_options(self):
        self.distribution.ext_modules = get_ext_modules()
        install.finalize_options(self)


setup(
    name="example",
    version="0.1",
    py_modules=["example"],
    install_requires=[
        "cffi",
    ],
    setup_requires=[
        "cffi",
    ],
    cmdclass={
        "build": CFFIBuild,
        "install": CFFIInstall,
    },
    zip_safe=False,
)
```

Now if we recreate our sdist instead of an error that says something like
``ImportError: No module named 'cffi'`` we'll get a successful installation
and we can verify that this is the case by executing our module:

```console
$ python -m example
Hi There!
```

We've gotten a sdist that can be sent to PyPI and others can install it,
however there are still a number of issues with our package. These problems
will crop up in strange cases with hard to debug errors. The problems that
we'll still have are:

1. The artifacts produced by default by CFFI have a hard dependency on a
   particular CFFI version, making it impossible to upgrade CFFI without
   rebuilding any package that uses it.
2. Installing the project does a double compile, one of which will cause
   problems for anyone trying to cross compile the software.
3. The implicit compile which can be very helpful in development will often
   mask problems like #2 on a local machine, if you upgrade your version of
   CFFI the next time you import the module it will simply implicitly
   recompile the C extension. This however will break in common deployment
   scenarios where the executing user does not have write permissions to the
   ``site-packages`` folder or where they installed a binary package and they
   do not have a compiler or development headers installed on the machine.


The problem in #1 is that behind the scenes CFFI generates a module name that
it will compile and load. This module name contains a hash of a few things like
the Python version (major and minor), the CFFI version, the string passed into
the ``FFI`` instance, and most of the keyword arguments to the
``FFI().verify()`` function. The idea behind this is that if any of these
things changed then the ABI might have changed so it's a good idea to rebuild
the extension module. The inclusion of the CFFI version causes #1, so to fix it
we'll compute our own hash and tell CFFI to use it instead.

First we'll create a function which computes our module name and then we'll
pass that into the ``FFI().verify()`` call so that CFFI will use our computed
module name instead.

The ``example.py`` file now looks like:

```python
import binascii
import sys

from cffi import FFI


def _create_modulename(cdef_sources, source, sys_version):
    """
    This is the same as CFFI's create modulename except we don't include the
    CFFI version.
    """
    key = '\x00'.join([sys_version[:3], source, cdef_sources])
    key = key.encode('utf-8')
    k1 = hex(binascii.crc32(key[0::2]) & 0xffffffff)
    k1 = k1.lstrip('0x').rstrip('L')
    k2 = hex(binascii.crc32(key[1::2]) & 0xffffffff)
    k2 = k2.lstrip('0').rstrip('L')
    return '_Example_cffi_{0}{1}'.format(k1, k2)


CDEF = """
    int printf(const char *format, ...);
"""

SOURCE = """
    #include <stdio.h>
"""


ffi = FFI()
ffi.cdef(CDEF)

c = ffi.verify(
    SOURCE,
    modulename=_create_modulename(CDEF, SOURCE, sys.version),
)


if __name__ == "__main__":
    c.printf(b"Hi There!\n")

```

Now we can upgrade our CFFI version without needing to recompile all of our
CFFI using projects. Installing this example project still requires building
the C extension twice and the implicit compile is still there lurking in the
shadows waiting to mask hidden errors.

The first of our two compiles is the implicit compile which happens when the
``FFI().verify()`` function is called when the ``setup.py`` imports the
example module and the second compile comes from distutils itself compiling
the module for install. We want to *only* have distutils compile our module
because there is a lot of tooling out there that has learned how to work with
distutils and it will avoid issues like left over files or various cross
compiling woes.

In order to stop CFFI from implicitly compiling on module import we need to
stop calling the ``FFI().verify()`` function. However we need the
``FFI().verifier`` object to get the ``Extension`` object that we need to pass
into ``ext_modules()`` and the ``FFI().verifier`` object is setup and created
by the ``FFI().verify()`` function. So what we'll do is instead of calling
``FFI().verify()`` we'll go ahead and construct our own ``Verifier()`` instance
and assign it to ``FFI().verifier``. We'll also need to call
``FFI().verifier.load_library()`` but we **MUST** ensure that this does not
happen when importing the module, it **MUST** be deferred to a later time so
we'll use a small shim class which will act as a stand in for the loaded
library and will defer loading the library until the first attempt to call
a C function.

The ``example.py`` file now looks like:

```python
import binascii
import sys
import threading

from cffi import FFI
from cffi.verifier import Verifier


def _create_modulename(cdef_sources, source, sys_version):
    """
    This is the same as CFFI's create modulename except we don't include the
    CFFI version.
    """
    key = '\x00'.join([sys_version[:3], source, cdef_sources])
    key = key.encode('utf-8')
    k1 = hex(binascii.crc32(key[0::2]) & 0xffffffff)
    k1 = k1.lstrip('0x').rstrip('L')
    k2 = hex(binascii.crc32(key[1::2]) & 0xffffffff)
    k2 = k2.lstrip('0').rstrip('L')
    return '_Example_cffi_{0}{1}'.format(k1, k2)


class LazyLibrary(object):
    def __init__(self, ffi):
        self._ffi = ffi
        self._lib = None
        self._lock = threading.Lock()

    def __getattr__(self, name):
        if self._lib is None:
            with self._lock:
                if self._lib is None:
                    self._lib = self._ffi.verifier.load_library()

        return getattr(self._lib, name)


CDEF = """
    int printf(const char *format, ...);
"""

SOURCE = """
    #include <stdio.h>
"""


ffi = FFI()
ffi.cdef(CDEF)
ffi.verifier = Verifier(
    ffi,
    SOURCE,
    modulename=_create_modulename(CDEF, SOURCE, sys.version),
    # ... Any other arguments that were being passed to FFI().verify()
)

c = LazyLibrary(ffi)


if __name__ == "__main__":
    c.printf(b"Hi There!\n")
```

The ``LazyLibrary`` class will defer the actual loading of the library until
the first time an attribute is accessed on it, and will otherwise just act
as a proxy to the underlying C library. It is important to make sure that you
do **not** access any attributes on the ``LazyLibrary()`` object in a way that
will execute during the import of the module.

Finally we still have the ability to implicitly compile our module. If all goes
well this will never happen during the normal installation and use of our
module, however it is deceptively easy to accidently do something which will
trigger an implicit compile and bring back the kinds of problems that
``LazyLibrary`` works around. Disabling the implicit compile is pretty easy,
however it requires patching the ``Verifier()`` instance to replace the
function that CFFI uses to compile modules with one that simply raises an
error.

The ``example.py`` file now looks like:

```python
import binascii
import sys
import threading

from cffi import FFI
from cffi.verifier import Verifier


def _create_modulename(cdef_sources, source, sys_version):
    """
    This is the same as CFFI's create modulename except we don't include the
    CFFI version.
    """
    key = '\x00'.join([sys_version[:3], source, cdef_sources])
    key = key.encode('utf-8')
    k1 = hex(binascii.crc32(key[0::2]) & 0xffffffff)
    k1 = k1.lstrip('0x').rstrip('L')
    k2 = hex(binascii.crc32(key[1::2]) & 0xffffffff)
    k2 = k2.lstrip('0').rstrip('L')
    return '_Example_cffi_{0}{1}'.format(k1, k2)


def _compile_module(*args, **kwargs):
    raise RuntimeError(
        "Attempted implicit compile of a cffi module. All cffi modules should "
        "be pre-compiled at installation time."
    )


class LazyLibrary(object):
    def __init__(self, ffi):
        self._ffi = ffi
        self._lib = None
        self._lock = threading.Lock()

    def __getattr__(self, name):
        if self._lib is None:
            with self._lock:
                if self._lib is None:
                    self._lib = self._ffi.verifier.load_library()

        return getattr(self._lib, name)


CDEF = """
    int printf(const char *format, ...);
"""

SOURCE = """
    #include <stdio.h>
"""


ffi = FFI()
ffi.cdef(CDEF)
ffi.verifier = Verifier(
    ffi,
    SOURCE,
    modulename=_create_modulename(CDEF, SOURCE, sys.version),
    # ... Any other arguments that were being passed to FFI().verify()
)

# Patch the Verifier() instance to prevent CFFI from compiling the module
ffi.verifier.compile_module = _compile_module
ffi.verifier._compile_module = _compile_module

c = LazyLibrary(ffi)


if __name__ == "__main__":
    c.printf(b"Hi There!\n")
```

Now we finally have a simple project that calls into C using CFFI and which
can sanely be distributed to others and deployed onto production systems. This
will also work with all the common binary packages like [Wheels][].


## Bonus: "Better" setup_requires

One issue with the ``setup.py`` that I've written above is that it is going to
install CFFI and all of it's dependencies for any invocation of ``setup.py``,
even just for printing out the usage information with
``setup.py setup.py --help``. This is due to the fact that setuptools doesn't
really have the concept of a "build" dependency, which is what we really want
here, but instead it only has the concept of a dependency required to execute
the ``setup.py``. Thus setuptools installs the items listed in
``setup_requires`` for any invocation, because it doesn't know why that item
is in there, just that it is required at some point in it's execution.

We can limit this so that setuptools will only install CFFI if required,
however it requires adding more logic to our ``setup.py``. This isn't strictly
required though users may appreciate being able to query information from the
``setup.py`` without downloading and installing CFFI.

To do this we'll create a function that will inspect the arguments that
``setup.py`` was called with and determine if any of them are invoking
something which will require CFFI in ``setup_requires``. This function can then
add additional keyword arguments to the ``setup()`` function call depending on
if we need CFFI in the ``setup_requires`` or not.

This will create a ``setup.py`` that looks like:

```python
import sys

from distutils.command.build import build
from setuptools import setup
from setuptools.command.install import install


SETUP_REQUIRES_ERROR = (
    "Requested setup command that needs 'setup_requires' while command line "
    "arguments implied a side effect free command or option."
)

NO_SETUP_REQUIRES_ARGUMENTS = [
    "-h", "--help",
    "-n", "--dry-run",
    "-q", "--quiet",
    "-v", "--verbose",
    "-v", "--version",
    "--author",
    "--author-email",
    "--classifiers",
    "--contact",
    "--contact-email",
    "--description",
    "--egg-base",
    "--fullname",
    "--help-commands",
    "--keywords",
    "--licence",
    "--license",
    "--long-description",
    "--maintainer",
    "--maintainer-email",
    "--name",
    "--no-user-cfg",
    "--obsoletes",
    "--platforms",
    "--provides",
    "--requires",
    "--url",
    "clean",
    "egg_info",
    "register",
    "sdist",
    "upload",
]


def get_ext_modules():
    import example
    return [example.ffi.verifier.get_extension()]


class CFFIBuild(build):
    def finalize_options(self):
        self.distribution.ext_modules = get_ext_modules()
        build.finalize_options(self)


class CFFIInstall(install):
    def finalize_options(self):
        self.distribution.ext_modules = get_ext_modules()
        install.finalize_options(self)


class DummyCFFIBuild(build):
    def run(self):
        raise RuntimeError(SETUP_REQUIRES_ERROR)


class DummyCFFIInstall(install):
    def run(self):
        raise RuntimeError(SETUP_REQUIRES_ERROR)


def keywords_with_side_effects(argv):
    def is_short_option(argument):
        """Check whether a command line argument is a short option."""
        return len(argument) >= 2 and argument[0] == '-' and argument[1] != '-'

    def expand_short_options(argument):
        """Expand combined short options into canonical short options."""
        return ('-' + char for char in argument[1:])

    def argument_without_setup_requirements(argv, i):
        """Check whether a command line argument needs setup requirements."""
        if argv[i] in NO_SETUP_REQUIRES_ARGUMENTS:
            # Simple case: An argument which is either an option or a command
            # which doesn't need setup requirements.
            return True
        elif (is_short_option(argv[i]) and
              all(option in NO_SETUP_REQUIRES_ARGUMENTS
                  for option in expand_short_options(argv[i]))):
            # Not so simple case: Combined short options none of which need
            # setup requirements.
            return True
        elif argv[i - 1:i] == ['--egg-base']:
            # Tricky case: --egg-info takes an argument which should not make
            # us use setup_requires (defeating the purpose of this code).
            return True
        else:
            return False

    if all(argument_without_setup_requirements(argv, i)
           for i in range(1, len(argv))):
        return {
            "cmdclass": {
                "build": DummyCFFIBuild,
                "install": DummyCFFIInstall,
            }
        }
    else:
        return {
            "setup_requires": ["cffi"],
            "cmdclass": {
                "build": CFFIBuild,
                "install": CFFIInstall,
            }
        }


setup(
    name="example",
    version="0.1",
    py_modules=["example"],
    install_requires=[
        "cffi",
    ],
    zip_safe=False,
    **keywords_with_side_effects(sys.argv)
)
```


## Conclusion and the Future

CFFI is a great tool for calling into C from within Python and while it does
have a number of problems when it comes to packaging up software using CFFI
none of those issues are deal breakers or which can't be worked around in some
fashion. All of the techniques shown here were taken from the [cryptography][]
project which can be used as a reference for any changes to these techniques
as well as an example of them being used in a real life project.

[cryptography]: https://cryptography.io/

Looking towards the future I plan to upstream these ideas and I will blog again
when they've been resolved inside of CFFI itself.
