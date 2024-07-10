---
title: Powering the Python Package Index
date: 2016-05-14
---

_Note: This was published in 2016. A update for 2021 is [here](https://dustingram.com/articles/2021/04/14/powering-the-python-package-index-in-2021/)._

The Python Package Index, or as most call it "PyPI" is a central part of the
ecosystem of Python. It serves as a central registry of names, helping to
prevent collision between different projects as well as the default repository
that most Python users go to when looking for software. Though it has its
issues (of which, there are many) it functions as a critical part of the user
experience of Python and is a critical part of the development infrastructure
for a veritable army of developers. It may not be the largest site in the
world, but it's certainly a significant one, having used 293.1TB of bandwidth
serving 3 billion HTTP requests during the month of April 2016 alone.

For most, what powers this service is largely opaque to them — it's (usually)
there when they need it and who or what powers it is largely a mystery to them,
but what and who really powers PyPI? [^1]


# People

I suspect that for many people this is going to come as the largest surprise,
although probably not for anyone who is familiar with how little investment
F/OSS, and F/OSS infrastructure in particular tends to get, but when you're
talking about the people powering the current version of PyPI you're largely
talking about 3 people in total.


## Donald Stufft (Me)

When it comes to PyPI the vast bulk of what happens falls squarely on my
shoulders. This includes some of the good parts but also most of the bad parts
as well. Most decisions that end up getting made are made or passionately
advocated for by me and very little gets done without me touching it in some
way. My responsibilities range from maintenance of the current code base (aka
"Legacy PyPI"), to development of the new replacement (aka "Warehouse"), to
operations and being one of the defacto on call persons 24/7 [^2].

Working on PyPI (along with pip and the general packaging ecosystem) is my full
time job which means at a minimum I spend ~40 hours a week working on one of
these pieces of the ecosystem (lately it's been largely PyPI). That minimum of
40 hours is very rarely what I actually spend working on these projects, my
total time very often looks more like 70-90 hours a week (or more!) [^3] that I
spend doing some sort of packaging related task [^4].


## Ee Durbin

When it comes to PyPI and ops, most of this has been done by Ee. When PyPI
migrated to it's new infrastructure host Ee more or less single handedly
wrote the entire salt states and pillars (339 out of 410 commits). They are one
of the people who are *actually* on call and has been a massive help in
architecting the modern PyPI infrastructure to handle the load we've placed on
it as well as be as reliable as we can get it given the state of the code that
powers all of this [^5].


## Richard Jones

The father of PyPI! Richard wrote PyPI all those years ago and has stood as one
of the administrators since then. While he has stepped back from the day to day
development and maintenance of PyPI he is still the main person dealing with
support requests on the issue tracker.


# Companies / Services

Given the skeleton crew that we run PyPI with, we decided a few years ago to
try and push as much of the operations work as we can onto external services.
This allows us to spend less time doing day to day operations and helps narrow
it down to largely incident response (security updates, downtime, etc). If it
wasn't for the companies here [^6] we simply would not be able to keep up with
work load (to whatever extent we're able to "keep up" today). Each of these
companies donate their services to the running of PyPI, and PyPI is all the
better for it.

I recently did the math, and omitting HPE and my salary from the equation and
focusing on just the actual hosting costs, all together these companies are
donating roughly $35,000 a month worth of services towards keeping PyPI up and
running.


## Hewlett Packard Enterprise

Technically Hewlett Packard Enterprise (HPE) is not actually donating a
service, but what they are essentially donating is me. They employ me full time
to work on all of this and give me free reign to work on the areas that I think
most need it. Without HPE the time I have would be severely reduced.


## Fastly

Fastly is PyPI's secret scaling sauce. The global CDN and Varnish caching
provided by Fastly provides one of the single largest reduction in operations
effort that we have. Every request to PyPI goes through Fastly and through
their caching we're able to prevent almost 90% of the incoming traffic from
ever reaching the origin servers. This also allows us to take advantage of the
cache (including stale cached items) so that whenever we do have downtime on
the origin servers it affects fewer people as we're able to serve it out of the
cache rather than giving the end user an error.


## Rackspace

The bulk of the infrastructure that we (the PSF) actually run is running on
cloud servers provided by Rackspace. Without this we'd have nothing to actually
run PyPI itself on and let me tell you, coming from a time when PyPI was ran on
a single physical host the ability to spin up new machines at will and have
actual support people making sure those machines keep running has decreased the
MTTR (Mean-Time-To-Recovery) by orders of magnitude.


## Amazon

PyPI hosts files, and unsurprisingly it needs a place to store those files,
which we do in the excellent object store by Amazon, S3. While there's not a
lot you can say about storage except that we stick our files in, and they make
sure we don't lose them and they're available whenever someone tries to
download a file.


## Heroku

Other than files, we also need a database for PyPI which is provided by the
excellent Heroku Postgres service. Offloading our database to Heroku allows us
to forget about dealing with HA and Master elections, fail over, and back ups.


## Elastic

The Elasticsearch cluster is running on Elastic Cloud, allowing us to free up
VM resources from hosting ES to other more specialized tasks and also
alleviating the need to keep Elasticsearch monitored and operational.


## Others

More than the above donate to the running of PyPI in ways that aren't on the
critical path of serving a web request, like:

* Dreamhost, providing long term log archival inside of DreamObjects.
* Statuspage.io, providing a managed status page hosted outside of our own
  infrastructure.
* Sentry, providing error reporting.
* Dyn, providing DNS hosting.


# Monetary

Due to a volunteer (or donated) work force and running on pretty much entirely
donated infrastructure the actual real monetary cost of PyPI is very low.
However, wherever we do need to spend money, that funding comes from the PSF
so the funding comes from donations to the PSF as well as the income generated
by events like PyCon.


# Final Words

This shows a snapshot of the people, services, and money that powers PyPI today
in May of 2016. It doesn't reflect efforts outside of the current PyPI such as
Warehouse, pip, setuptools, the ongoing PEPs, etc. As we move forward this is
bound to become outdated as our infrastructure changes.


[^1]: Over the years many different people and services have participated in
      the maintenance and running of PyPI. I'm not going to attempt to create
      an exhaustive list of every person or service who has ever helped, but
      instead focus on those who are currently involved. This is not to lessen
      the impact of those who came before, but merely to avoid ballooning an
      already long post even more. Even limiting to just the present, I'm sure
      that I've missed someone and for that I am deeply sorry!

[^2]: I'm very rarely *actually* on call. We do have Pager Duty and Pingdom
      setup to monitor PyPI that will send notifications to a mailing list when
      things go down and also to Ee Durbin and Noah Kantrowitz. However,
      I'm fairly publicly associated with PyPI and it's rare that an issue
      occurs with it that doesn't end up with people pinging me on IRC,
      Twitter, Email, etc, often times faster than Pingdom can notice.
      Realistically the only way for me to avoid notification whenever PyPI
      has downtime is to disconnect myself completely from any public method of
      contacting me.

[^3]: Right about here is where [Glyph](https://twitter.com/glyph) starts
      involuntarily twitching and linking me to his
      [excellent post](https://glyph.twistedmatrix.com/2016/01/stop-working-so-hard.html)
      on how we're all working too damn much.

[^4]: You want to know who the real heros of F/OSS are? It's the spouses,
      families, and friends of those who work on it who put up with someone
      they know taking time they could be spending with them and choosing to
      help out a bunch of strangers on the internet. There are times when the
      only time I really interact with my wife is lunch and the 10 minutes
      between when I lay down at night and finally pass out. She often times
      calls herself a "Software Widow" with a varying level of amusement
      depending on long it's been since I had a particularly overloaded week.

[^5]: Fun fact, the code that powers all of this? Yea it was a weekend hack for
      a proof of concept that was intended to get quickly replaced by the
      *real* code. Over a decade later? Yea that became critical infrastructure
      for most Python developers. This code predates modern Frameworks by years
      and it either predates or was a contemporary of WSGI. It's had numerous
      things bolted onto the side of it over the years, turning it into
      ~~Frankenstein's~~ Jones' Monster.

[^6]: Much like with the people, there have been a variety of companies willing
      to provide services over the years, some of which we've either stopped
      using or have stopped offering it. While we thank them for the help
      they've given, this post is largely focusing on the present. I'm also
      sure that I've missed some, and for that I am sorry!
