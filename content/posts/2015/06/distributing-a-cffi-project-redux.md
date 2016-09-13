---
title: Distributing a CFFI Project Redux
date: 2015-06-29T15:15:00-05:00
---

A little over six months ago, I wrote about how to
[enable sane distribution of CFFI][]. That previous post contained a number of
work arounds and hacks to deal with a single design decision in CFFI, namely
that it would implicitly invoke a compiler to compile your module and that was
a core part of the API. A little over a month ago, CFFI 1.0 was released which
offered new APIs which changed that assumption and offered better integration
with setuptools. There are still a few things to keep in mind while writing
a CFFI using module to enable easy and sane distribution, however it is now
much easier to do so.

I'm going to adapt the original examples from my previous post to use the new
APIs so we can see how it's changed, and what the new best way of distributing
a CFFI based project is.

[enable sane distribution of CFFI]: /2014/11/distributing-a-cffi-project/


## Minimal Example

Here is a minimal example of using CFFI to be able to call the ``printf``
function from Python:

```python
# This file should be saved as example_build.py
from cffi import FFI

ffi = FFI()

ffi.cdef(
    """
    int printf(const char *format, ...);
    """
)

ffi.set_source(
    "_example",  # This is the name of the import that this will build.
    """
    #include <stdio.h>
    """
)


if __name__ == '__main__':
    ffi.compile()
```

```python
# This file should be saved as example.py
from _example import ffi, lib

if __name__ == "__main__":
    lib.printf(b"Hi There!\n")
```

This example works, and if you save both files into your current directory you
can verify it by running:

```console
$ python example_build.py
$ python example.py
Hi There!
```

This works because when you first execute ``example_build.py`` it will
construct a FFI object at the module scope, and then execute the ``compile()``
method on that FFI object. This will cause CFFI to compile the ``_example.so``
module which is a standard Python extension module that you can simply import.
This can let you quickly and easily write simple modules with a minimal amount
of overhead.


## Packaging our Example Project

Now that we have a simple ``example.py`` file we can package this up so that we
can distribute it to other people. We'll use a simple ``setup.py`` taken from
the CFFI docs with some slight modifications to fit our project:

```python
from setuptools import setup

setup(
    name="example",
    version="0.1",
    py_modules=["example"],
    setup_requires=["cffi>=1.0.0"],
    install_requires=["cffi>=1.0.0"],
    cffi_modules=["example_build.py:ffi"],
)
```

Now that we have our ``setup.py`` we can go ahead and create a sdist using the
command ``python setup.py sdist`` which will give us ``example-0.1.tar.gz`` in
the ``dist/`` folder. We can even publish it to PyPI and then let other users
install it using ``pip install example``!

Right about here is where my previous post started to layer more and more hacks
ontop of everything in order to restore some sanity to distributing. The good
news is CFFI 1.0 fixed all of this and we're already done! People installing
this distribution will require a few system dependencies like the Python
development headers and libffi and its development headers however there is no
longer a need for all of the layers of monkeypatching and hacks.

The one really subtle thing I would point out here that isn't obvious in our
example, is that you should not install the build scripts. When you're simply
shipping a single ``.py`` file (such as in the example) then you can handle
this by simply not adding the ``example_build.py`` (or whatever name your
script has) to the ``py_modules`` list. However if you're instead packaging
an importable package (e.g. modules inside of a directory) then you would
instead want do something like this:

```python
# This should be saved as _cffi_build/example_build.py
from cffi import FFI

ffi = FFI()

ffi.cdef(
    """
    int printf(const char *format, ...);
    """
)

ffi.set_source(
    "_example",  # This is the name of the import that this will build.
    """
    #include <stdio.h>
    """
)
```

```python
# This should be saved as example/__init__.py
from example._example import ffi, lib

if __name__ == "__main__":
    lib.printf(b"Hi There!\n")
```

Then, we can have a ``setup.py`` that looks something like:

```python
from setuptools import find_packages, setup

setup(
    name="example",
    version="0.1",
    packages=find_packages(exclude=["_cffi_build", "_cffi_build.*"]),
    setup_requires=["cffi>=1.0.0"],
    install_requires=["cffi>=1.0.0"],
    ext_package="example",
    cffi_modules=["_cffi_build/example_build.py:ffi"],
)
```

This will have the same outcome as the first example, you'll get the example
project installed without installing the build script.


## Bonus: "Better" setup_requires

Sadly, a better CFFI still doesn't solve the issues around ``setup.py`` and
setuptools, particularly that the ``setup.py`` as written above will install
CFFI and all of its dependencies for any invocation of ``setup.py``, even just
for printing out the usage information with ``python setup.py --help``. The
``setup_requires`` dependencies exist there to allow CFFI to introduce the
``cffi_modules`` keyword, however setuptools doesn't know in which cases you
actually want to install the ``setup_requires`` and in which cases they are
superflous, so it just always installs them.

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
            "setup_requires": ["cffi>=1.0.0"],
            "cffi_modules": ["example_build.py:ffi"],
        }


setup(
    name="example",
    version="0.1",
    py_modules=["example"],
    install_requires=["cffi>=1.0.0"],
    **keywords_with_side_effects(sys.argv)
)
```
