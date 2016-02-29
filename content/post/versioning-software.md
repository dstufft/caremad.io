---
title: Versioning Software
date: 2016-02-29
---

When you're writing a piece of software, whether it's a library or an
application, one of the things that you'll need to decide is how you're going
to version that software. The most popular way to version software is using
[SemVer](https://semver.org) or something that looks roughly similar to it, if
not explicitly that. A small, but not insignificant, number of projects buck
the trend and instead use some form of a date based version, dubbed
[CalVer](http://sedimental.org/designing_a_version.html#calendar_versioning) by
Mahmoud Hashemi.

The general idea behind SemVer is that you communicate how large of a change
you intended a particular release to be from a previous release. If there are
only bugfixes? Simple! Just increase ``X.Y.Z+1``. Add a new feature? That's
great! You want ``X.Y+1.0``. Break something that will require users to change
how they're doing something? Sad, but you want ``X+1.0.0``. By communicating in
your version number what impact you intended to have, you can tell users how
much effort they can hopefully expect to expend upgrading to that library.

> Meanwhile, minor updates break software all over the world.
> — [Hynek](https://twitter.com/hynek/status/704264578990018560)

The arguments for CalVer generally fall along the line that because SemVer is
imperfect at describing if a particular change will break someone upgrading the
software, that we should instead throw it out and replace it with something
that doesn't purport to tell us that information. The sad fact of life is that
no matter how careful you are, the more popular your library is the more likely
it is that *any* change is going to break someone [^1]. Another argument
against SemVer is that SemVer "punishes" fast moving libraries by forcing them
to increase their major version regularly which causes people to judge that
project derisively. The argument is that CalVer removes this burden, allowing
projects to iterate without fear of judgement for their version number.


## SemVer is nothing but lies!

![Throne of Lies](/images/versioning-software/throne-of-lies.gif)

SemVer encodes intent into the version number and uses that as a way for the
project to communicate that intent to its users. However, it cannot do this
perfectly, even ignoring the case of non-public API which is not covered by
SemVer at all [^2]. Since this information is often inaccurate, it cannot be
trusted and you must rely on something else to tell you what the impact of
upgrading will be.

Often the first thing that people will point to is the change log that many
projects keep. Assuming that the project keeps a good and detailed changelog,
this will tell you what the impact upgrading will be. However, this falls into
the same problem as before, while a change log is more descriptive, it still
only tells you what changes (or breakages) a project *intended* to make, it
doesn't go into any detail about unintended consequences of changes made.
Ultimately, a change log's accuracy is no different than that of the version
itself, it is just (hopefully!) more detailed.

It is true that by adding more detail an end user, who is familar with how
they are using a particular piece of software [^3], will get a better idea of
what impact an upgrade is going to have on them. If we take this idea to it's
logical conclusion, than we shouldn't publish change logs either, since they
are a lossy encoding of the *real* changes between two versions, and instead we
should just publish a diff and expect everyone to read that [^4]. After all,
more detail is better right?

Fundamentally, any indicator of change that isn't a full diff is just a lossy
encoding of that diff. How much detail you're willing to lose when evaluating
whether to upgrade is going to depend greatly on how important that particular
library is to your application. On one application I work on, I just blindly
upgrade the [raven](https://pypi.python.org/pypi/raven) dependencies regardless
of what its version is — It doesn't have much of an API of it's own (as I use
it, via logging) so there is little chance for it to break. On another project
I work on, I look at the full diff between two versions of requests before
upgrading it, because we interact pretty closely with it, even touching some
internal pieces, and it's unlikely that anything but a full diff will have
enough detail.

Encoding this information in the version is just an extremely lossy, but very
fast to parse and interpret, means of communicating this information. It makes
it easy for someone to get an idea how much work upgrading the library is
likely to be.

The elephant in the room is that no matter what level of detail you give, even
a full diff, there really is no way to tell if something is going to break you
other than trying it out and see what breaks, hopefully via automated testing.
While proponents of CalVer tend to use this as evidence of SemVer's failing, I
don't believe that to be the case. If I see something has bumped only as a
micro version, indicating the project intends this to break nothing but only
fix bugs, then I might do a quick version bump in my downtime between other
activities without investigating too much further into what exactly changed. If
instead, I see a major version bump, I'll take a look at the changelog to see
what changed and I'll dedicate more time to investigating what changed and,
depending on what did change, carve out more time to actually migrate to the
newer version.

At the end of the day, I'll still rely on the tests to tell me if something
actually broke in production, but I'll use the information available to me to
determine how much investigation I'm likely to need to do and how painful of an
upgrade I might be looking at. If all I'm given is a CalVer style version then
I'm forced to either dedicate more time to investigate each version, or to
blindly attempt to upgrade and hope for the best, or to assume that every
change is a breaking change and hold off on upgrading until I have time to
fix any breakages that might occur.


## Your version is what?

![I'm Judging You](/images/versioning-software/judging-you.jpg)

Another major argument is that people inherently judge a project based on what
it's version number is. They'll implicitly assume that foo 2.0 is better than
bar 1.0 (and frob 3.0 is better still) because the version numbers are higher.
However, there is a limit to this, if you go too high too quickly, people
assume your project is unstable and shouldn't really be used, even if the
reason that your project is so high is because you removed some tiny edge cases
that nobody actually used and didn't actually impact many people, if any, at
all.

These are two different expressions of the same thing. The first is that people
will look down on a project for not having a high enough version compared to
its competitors. While it's true that some people will do this, I don't believe
that it is a significant reason to throw away the communication benefits of
your version number. Instead of focusing on promoting a "2.0" release, try
giving your release a code name (or a marketing name) and promoting that
instead. Ultimately though, no matter what you do, people who judge a project
as inferior because of something as shallow as "smaller version number" will
find some other, equally shallow, reason to pick between projects.

The other side of this is a bit different. When you have a large major version,
like 42.0.0, people assume that your library is not stable and that you
regularly break compatibility and if you follow SemVer strictly, it does
actually mean that you regularly break compatibility.

I see two general cases that this happens. The first of these is what I tend to
think of as a true positive. A project that does routinely break it's public
API in meaningful ways that make every major version require end users to
adjust their use of your library. While every project is free to choose
whatever compatibility policy they want, I view this as a generally reasonable
outcome. In parenting there is the concept of a "Natural Consequence", which
are consequences that are the inevitable result of a child's own choices. While
developers are often not (but sometimes are!) children, the same idea follows,
if people who you want to use your software value stability and compatibility
over constant changes, then it is an inevitable result that they are going to
view such a project negatively. The version number isn't the problem, it is
just honestly describing how the project is maintained, the problem is a
mismatch between what the user's and the authors want and are willing to
accept/promise.

The other side of this, is that strictly adhereing to SemVer means that *any*
change to the public API which is not backwards compatible requires bumping a
major version. This means that if you remove some function that nobody actually
uses [^5] you need to increase your major version. Do it again and you need to
increase your major version again. Do this enough times, for even very small
changes and you can quickly get into a large version number [^6] and people
will assume that you're the kind of project that doesn't value stability. In
this case, this is a false positive for the "stability" test, because the
reality is that your project is actually quite stable.

For these projects, I think that the solution isn't exactly clear because it
depends on exactly what they're doing. In some cases, it's trivial to maintain
compatibility, for example the argument to a function had a typo in the name,
so you can instead just accept *both* names (and likely error if both are
provided). In other cases, I think it is best to just bunch up a bunch of these
smaller, minor improvments and land them at once or grouped with other, more
major changes. Finally, it's sometimes better to follow the "spirit" of SemVer
rather than the letter of SemVer, if you know that nobody is using something
(perhaps because it never actually worked!) then removing it in a less than
major version bump may be reasonable.


## So I should use SemVer then?

![The code is more like guidelines, rather than actual rules](/images/versioning-software/guidelines-not-rules.jpg)

I believe that projects should generally default to SemVer-ish, following the
spirit of the documentation rather than the letter of the specification. Your
version number is a means of communicating to your end users, and nobody knows
what sort of changes are most important to reflect in your version number more
than the people who are actually involved with the project.

I do believe it is important to call out one particular section from the
SemVer 2.0 FAQ that I think doesn't get enough attention:

> If your software is being used in production, it should probably already be
> 1.0.0. If you have a stable API on which users have come to depend, you
> should be 1.0.0. If you’re worrying a lot about backwards compatibility, you
> should probably already be 1.0.0.

Just because SemVer allows you to make breaking changes in a ``0.X+1.0`` does
not mean that you should just hold out with a ``0.X`` version number as long as
possible until you think the software is "perfect" and "deserving" of a 1.0
release. Any software that you expect or know that users are using in
production should almost certainly be a 1.0 already and if it isn't, should get
a 1.0 release in the near future.

There are however, cases where I see a CalVer based version being superior, but
those are certainly the exception rather than the rule in my opinion. Cases
such as:

* You're tracking something that is already versioned using dates or for which
  the version number can only really be described as a point in time release.
  The [pytz](https://pypi.python.org/pypi/pytz/) is a good example of both of
  these cases, the Olson TZ database is versioned using a date based scheme and
  the information that it is providing is best represented as a snapshot of the
  state of what timezones were like at a particular poin in time.

* Your project is going to be breaking compatibility in every release and you
  do not want to make *any* promises of compatibility. You should still
  document this fact in your README, but if there's no promise of compatibility
  between releases, then there's no information to be communicated in the
  version number.

* Your project is *never* going to intentionally breaking compatibility in a
  release, and you strive to always maintain compatibility. Projects can
  always [^7] just use the latest version of your software. Your changes will
  only ever be additive, and if you need to change your API, you'll do
  something like leave the old API intact, and add a new API with the new
  semantics.

At the end of the day, the most important, but often overlooked, aspect of the
version is that one of it's primary purposes is to communicate with the end
users of the software. It's up to the project what information is most
important to their end users that it deserves to be communicated through the
version number, though I would suggest that for most projects, SemVer-ish is
likely to be best suited.


[^1]: The always great, Randall Munroe has succinctly pointed this out in
      [xkcd: Workflow](https://xkcd.com/1172/).

[^2]: A lot of the times, breakage that comes from upgrading comes from end
      users relying on something which isn't part of the project's public API,
      whether knowingly or because they had different assumptions about what
      was public than the project author(s) did.

[^3]: It's important to note that this really only holds true if you're aware
      of what API (programatic, CLI, or any other type) is being depended on
      and what assumptions are being made about that API. A consumer of say,
      setuptools might see a line in the change log like:

      > Dropped support for builds with Pyrex. Only Cython is supported.

      And have no idea what that means, do they install any projects that use
      Pyrex? How do they determine that? Your average end user is unlikely to
      have any idea what the impact of dropping Pyrex is. However, someone who
      is using Pyrex (or knows that a project is) will immediately see that
      their use case is no longer supported.

[^4]: You might think that I am joking here, but I know people who argue that
      version numbers should just be a serial number, and change logs should
      just be a diff between this version and the last.

[^5]: Though I would ask how you *know* that nobody is using it, but for the
      sake of argument we'll pretend that you do, or atleast are relatively
      sure that nobody is using it.

[^6]: For example, setuptools is at the time of writing, up to the major
      version of 20, even though the vast bulk of those breaking changes were
      very minor edge cases.

[^7]: "Always", in so much as it is possible to ever promise anything with
      regards to compatibility in software.
