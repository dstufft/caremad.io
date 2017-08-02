---
title: Hire me
date: 2016-10-17
---

*As of December 19th, 2016 I have found a new role at Amazon Web Services, for
more information, see the post "[A New Home](/posts/2017/01/a-new-home/)".*

For the past year and a half I've been employed by Hewlett Packard Enterprise to
work full time on improving and maintaining the Python community's packaging
toolchain. This critical investment in the Python ecosystem has enabled me to
push forward on efforts like Warehouse [^1], improving pip, new packaging
standards, and taking time to help out individual people who are having problems
with the current tooling. I'm very proud of what we've accomplished in this time
and that would not have been possible without HPE's support.

I am incredibly grateful of the time that HPE has given me. Unfortunately all
things must end and today I have been notified that, as part of a widespread
layoff, my last day at HPE will be October 28th.

So I'm looking for a new position! If you're a company looking for a developer
here's what you should know about me (besides what’s on my
[résumé](/career/resume.pdf)) and what I seek in a job.


# Me

I am obviously particularly interested in software distribution, and given my
role with PyPI and pip I have a particularly unique experience in designing and
operating an open source software distribution system at a fairly large
scale [^2]. However, outside of that I also have a interest in:

* Improving the security of computing and software.
* Designing APIs that are simple and easy to use.
* Developing tooling to help other developers be more effective.
* Paying down technical debt and "unsticking" stuck projects.
* Working with and contributing to Open Source communities and ecosystems.


# My Open source

I maintain and operate a number of popular Open Source projects such as
[PyPI](https://pypi.python.org/),
[Warehouse](https://github.com/pypa/warehouse/),
[pip](https://github.com/pypa/pip/), as well as a large number of less well
known but critical projects and efforts in the Python community. These projects
are relied upon by almost every Python developer and are *critical* to the
functioning of the Python ecosystem.

Due in large part to the subsidization of my time by HPE I have been able to
achieve (among many other things):

* Wrote a from-scratch rewrite of PyPI (currently available at
  https://pypi.org/ ) which focuses on maintainability and ease of contribution.
* Wrote a statistic processing pipeline that processes and stores 500+ million
  download events a month.
* Contributed to the maintenance of pip, including responding to pull requests
  acting as release manager, and acting as a point of contact for downstream
  redistributors.
* Removed insecure and unreliable external hosting completely from PyPI.
* Documented the "Simple" API for PyPI to allow interoperability for all PyPI
  consuming clients.
* Helped design a method that will be used as a stepping stone to allow making a
  ``setup.py`` file optional when distributing Python packages.
* Simplifying PyPI and consumers of PyPI by limiting the types of files and file
  extensions that can be used on PyPI.

I wish to continue this work, but doing so requires a nontrivial time commitment
(for an idea, see my previous post
[Powering the Python Package Index](/posts/2016/05/powering-pypi/)) which is not
realistically sustainable alongside a high-stress, 40 hour a week job. I seek
companies which understand **using volunteer software is a two-way street** and
value giving back to open source by subsidizing developer time.

This does *not* require a position where 100% of my time would be dedicated to
working on my Open Source projects, but the ideal position would involve a
reasonable amount of dedicated time as an investment back in the ecosystem and
community they're using. However, if you *are* willing to fully subsidize my
time for PyPI, then all the better!


# You

The following should describe you, the company:

* You must **support remote work**. I live in the exurbs of Philadelphia and
  have been working remote from home for almost my entire career.
  * If you don't have a large (or any) remote work force today, but you're
    willing to work with me to make it work that is OK as well.
* You should have a **positive culture** that doesn't pit people against each
  other and rewards hard work.


# Let's Talk!

If nothing above sounds like a deal-breaker, **please contact me**, preferably
via email at [donald@stufft.io](mailto:donald@stufft.io). Thanks!


[^1]: A rewrite of PyPI designed with modern tooling, ease of development and
      maintenance in mind from the beginning.

[^2]: PyPI sees over 3 billion HTTP requests and almost 400TB of bandwidth a
      month.
