---
title: Crate Discontinued and Under New Ownership
date: 2014-03-18
---

This is a Post hoc announcement that as of Dec 6th, 2013 I am no longer the
owner of the crate.io domain name. It is suggested that everyone linking to
or using any of the crate.io subdomains in their deployments revert back to
using PyPI proper.

## Rationale

In December of 2011 I became so frustrated with the state of PyPI that I
decided I could do it better and over a Christmas holiday I laid down the code
that eventually became Crate a few months later. Crate did a number of things
better than PyPI and a some people in the Python community liked what I was
doing and started pointing their deployments or their links towards Crate.

Fast forward to 2014 and I'm now a PyPI administrator and writing a replacement
to the legacy code base that currently hosts PyPI. Serving in this role has
allowed me to take the things that were good about Crate and bring them to a
much wider audience (for comparison, Crate averaged 100-200 hits a day, whereas
PyPI gets 90k+ in the web ui alone). Since becoming a PyPI administrator Crate
itself started falling into disrepair, there were several errors that were
occurring constantly and the code base itself made several deeply ingrained
assumptions that turned out to be bad and needed serious refactoring to be
fixed.

The broken state and lack of time or motivation to fix Crate and the tiny
fraction of traffic compared to PyPI proper lead to me to accept the offer to
sell the crate.io domain name and be able to focus fully on PyPI and pip.

## Going Forward

The new owners of Crate have pledged to keep the direct link to package pages
(such as [https://crate.io/packages/pip/](https://crate.io/packages/pip/))
redirecting to PyPI for as long as they are getting traffic [[1][1]].

In the near future I will be shutting down the servers that host
simple.crate.io, restricted.crate.io, and pypi.crate.io. If you are using any
of those in your deployments or locally then I urge you to switch back to PyPI.

[1]: https://crate.io/thanks-dstufft
