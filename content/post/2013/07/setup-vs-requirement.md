---
title: setup.py vs requirements.txt
date: 2013-07-22
---

There's a lot of misunderstanding between ``setup.py`` and ``requirements.txt``
and their roles. A lot of people have felt they are duplicated information and
have even created [tools][1] to handle this "duplication".


## Python Libraries

A Python library in this context is something that has been developed and
released for others to use. You can find a number of them on [PyPI][2] that others
have made available. A library has a number of pieces of metadata that need to
be provided in order to successfully distribute it. These are things such as
the Name, Version, Dependencies, etc. The ``setup.py`` file gives you the
ability to specify this metadata like:

```python
from setuptools import setup

setup(
    name="MyLibrary",
    version="1.0",
    install_requires=[
        "requests",
        "bcrypt",
    ],
    # ...
)
```

This is simple enough, you have the required pieces of metadata declared.
However something you don't see is a specification as to where you'll be
getting those dependencies from. There's no url or filesystem where you can
fetch these dependencies from, it's just "requests" and "bcrypt". This is
important and for lack of a better term I call these "abstract dependencies".
They are dependencies which exist only as a name and an optional version
specifier. Think of it like duck typing your dependencies, you don't care what
specific "requests" you get as long as it looks like "requests".


## Python Applications

Here when I speak of a Python application I'm going to typically be speaking
about something that you specifically deploy. It may or may not exist on PyPI
but it's something that likely does not have much in the way of reusability. An
application that does exist on PyPI typically requires a deploy specific
configuration file and this section deals with the "deploy specific" side of a
Python application.

An application typically has a set of dependencies, often times even a very
complex set of dependencies, that it has been tested against. Being a specific
instance that has been deployed, it typically does not have a name, nor any of
the other packaging related metadata. This is reflected in the abilities of a
[pip][3] requirements file. A typical requirements file might look something
like:

```ini
# This is an implicit value, here for clarity
--index-url https://pypi.python.org/simple/

MyPackage==1.0
requests==1.2.0
bcrypt==1.0.2
```

Here you have each dependency shown along with an exact version specifier.
While a library tends to want to have wide open ended version specifiers an
application wants very specific dependencies. It may not have mattered up
front what version of requests was installed but you want the same version
to install in production as you developed and tested with locally.

At the top of this file you'll also notice a
``--index-url https://pypi.python.org/simple/``. Your typical requirements.txt
won't have this listed explicitly like this unless they are not using PyPI, it
is however an important part of a ``requirements.txt``. This single line is
what turns the abstract dependency of ``requests==1.2.0`` into a "concrete"
dependency of "requests 1.2.0 from https://pypi.python.org/simple/". This is
not like duck typing, this is the packaging equivalent of an ``isinstance()``
check.


## So Why Does Abstract and Concrete Matter?

You've read this far and maybe you've said, ok I know that ``setup.py`` is
designed for redistributable things and that ``requirements.txt`` is designed
for non-redistributable things but I already have something that reads a
``requirements.txt`` and fills out my ``install_requires=[...]`` so why should I
care?

This split between abstract and concrete is an important one. It was what
allows the PyPI mirroring infrastructure to work. It is what allows a company
to host their own private package index. It is even what enables you to fork a
library to fix a bug or add a feature and use your own fork. Because an
abstract dependency is a name and an optional version specifier you can install
it from PyPI or from Crate.io, or from your own filesystem. You can fork a
library, change the code, and as long as it has the right name and version
specifier that library will happily go on using it.

A more extreme version of what can happen when you use a concrete requirement
where an abstract requirement should be used can be found in the
[Go language][4]. In the go language the default package manager (``go get``)
allows you to specify your imports via an url inside the code which the package
manager collects and downloads. This would look something like:

```go
import (
    "github.com/foo/bar"
)
```

Here you can see that an exact url to a dependency has been specified. Now if I
used a library that specified its dependencies this way and I wanted to change
the "bar" library because of a bug that was affecting me or a feature I needed,
I would not only need to fork the bar library, but I would also need to fork
the library that depended on the bar library to update it. Even worse, if the
bar library was say, 5 levels deep, then that's a potential of 5 different
packages that I would need to fork and modify only to point it at a slightly
different "bar".


### A Setuptools Misfeature

Setuptools has a feature similar to the Go example. It's called
[dependency links][5] and it looks like this:

```python
from setuptools import setup

setup(
    # ...
    dependency_links = [
        "http://packages.example.com/snapshots/",
        "http://example2.com/p/bar-1.0.tar.gz",
    ],
)
```

This "feature" of setuptools removes the abstractness of its dependencies and
hardcodes an exact url from which you can fetch the dependency from. Now very
similarly to Go if we want to modify packages, or simply fetch them from a
different server we'll need to go in and edit each package in the dependency
chain in order to update the ``dependency_links``.


## Developing Reusable Things or How Not to Repeat Yourself

The "Library" and "Application" distinction is all well and good, but whenever
you're developing a Library, in a way *it* becomes your application. You want a
specific set of dependencies that you want to fetch from a specific location
and you know that you should have abstract dependencies in your ``setup.py``
and concrete dependencies in your ``requirements.txt`` but you don't want to
need to maintain two separate lists which will inevitably go out of sync. As it
turns out pip requirements file have a construct to handle just such a case.
Given a directory with a ``setup.py`` inside of it you can write a requirements
file that looks like:

```ini
--index-url https://pypi.python.org/simple/

-e .
```

Now your ``pip install -r requirements.txt`` will work just as before. It will
first install the library located at the file path ``.`` and then move on to
its abstract dependencies, combining them with its ``--index-url`` option and
turning them into concrete dependencies and installing them.

This method grants another powerful ability. Let's say you have two or more
libraries that you develop as a unit but release separately, or maybe you've
just split out part of a library into its own piece and haven't officially
released it yet. If your top level library still depends on just the name then
you can install the development version when using the ``requirements.txt`` and
the release version when not, using a file like:

```ini
--index-url https://pypi.python.org/simple/

-e https://github.com/foo/bar.git#egg=bar
-e .
```

This will first install the bar library from https://github.com/foo/bar.git,
making it equal to the name "bar", and then will install the local package,
again combining its dependencies with the ``--index`` option and installing
but this time since the "bar" dependency has already been satisfied it will
skip it and continue to use the in development version.


_**Recognition:** This post was inspired by [Yehuda Katz's blog post][6] on a
similar issue in Ruby with ``Gemfile`` and ``gemspec``._

[1]: https://pypi.python.org/pypi/pbr/#requirements
[2]: https://pypi.python.org/pypi
[3]: http://pip-installer.org/
[4]: http://golang.org/
[5]: http://pythonhosted.org/setuptools/setuptools.html#dependencies-that-aren-t-in-pypi
[6]: http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/
