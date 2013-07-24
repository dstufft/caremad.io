Title: Why Package Signing is not the Holy Grail
Category: Python
Tags: packaging

Typically any time the topic of security and software packages, in my case
typically Python packages, comes up someone seems to come up with the "helpful"
suggestion of "Just Use X!", where X is typically GPG but can be any of a wide
range of signing technologies. Quite often the people suggesting it have
latched onto signing packages as some sort of voodoo you can throw at the
problem and magically get "security".


## The Boring Easy Part

Generation of package signatures is actually a pretty simple thing to implement
assuming you're using good libraries or tools to do it with. There is a number
of technologies from [OpenPGP][1] to [NaCl][2] to even commercially available
certificates from companies like Verisign. Most people look at the ease of
generating signatures, believe that's all it takes, and declare it done.
You can see an example of this with [PyPI][3]/[distutils][4]. Here the GPG
signatures are able to be generated and even uploaded to PyPI and yet nothing
uses them, and even if they did they couldn't be trusted.


## The Hard Part that (Almost) No One Thinks About

When attempting to verify a signed file you check the signature against a
public key. If the signature matches that public key then everything is kosher.
The question then becomes **which** public key, and therein lies the rub. If
you do not have a well defined model of trust then all you've done is thrown
cryptography at a problem in order to give the people involved the ability to
say that their system has signature verification.


### Let's Just Ask The Delivery Guy

One naive solution would be to simply upload the public key to the repository
as is done with PyPI. Then clients can simply download the public key and
verify it against the signature! However in this model if someone is able to
send you a malicious package they are also likely able to send you a malicious
key. Once they've sent you the malicious package and the malicious key your
client will happily verify it, claim all is well, and install it. If you trust
the repository to deliver to you the expected signing key and the package to be
verified you've gained nothing and introduced complexity.


### Linux Has Packaging Signing, Let's Steal Theirs

Another solution to solving this is to look at prior art and steal what they've
done. The most oft pointed to example is various flavors of Linux. On the
surface it looks like exactly what people want. When you install your Linux it
comes with a public key baked into the image and anytime you install packages
it verifies against that public key. You're no longer implicitly trusting the
repository to tell you what key you should trust because you already *know*
what key.

However, this has a number of issues too. The first issue that a repository
like PyPI would have with this system is simply one of scale. [Debian][5] or
[RedHat][6] have a small pool of developers who are able to make new packages,
making it easy to properly verify each person and sign their keys or otherwise
give them access. PyPI allows *anyone* to sign up and make a release which
makes verifying authors an unmanageable problem.

The second issue is that in addition to trusting the package authors, you are
trusting the entire build chain involved in producing the package. You don't
have to trust the repository which hands you the package, but trusting one
machine up the chain isn't all that different. If that machine got compromised
you could generate malicious packages that tools would blindly install. This
system does have one major advantage in that you have mirror validation built
in. Since the validation is based on the package, not on the mirror you
downloaded from, as long as the signature is valid you know it came from the
trusted build machine.


### Everyone is Connected, The Web of Trust

At this point in the argument, someone will typically bring up the web of trust
available in OpenPGP and say that it doesn't require trusting a single machine
nor does it require a small team to verify each author. This is getting much
closer to a solution that *technically* is almost a solution but it's lacking
a very critical piece.

With the OpenPGP Web of Trust you're signing the identity of the author. What
you're not doing, and what there is no method of doing to my knowledge, is
gaining any assurance that the person whose identity you've verified has any
right to sign the package you're verifying. This means that if you trust Bob
because you want to use his "foo" package, you also trust him to sign for the
"bar" package, even though that belongs to Alice. This brings us back to the
original problem of trying to determine if the key we have is trusted for this
package.

The other major problem with the Web of Trust is its user experience. If
you start requiring every person who wants to release a package to participate
in the Web of Trust you've now drastically reduced the number of people who are
willing to publish packages out of confusion, laziness, or even ability.
Further more it encourages people to sign keys in order to make their packages
work and not because they actually have any reason to trust that person.


### It Says Secure Right in the Name

Another suggestion I've seen is adopting a model similar to that of SSH, that
is the first time you install a package you're prompted to accept the key and
from then on out it will remember that and use that as the trusted key. As you
might have guessed by now, this solution also has problems besides the obvious
issue that people are vulnerable during the first install.

Packages on PyPI change hands, get deleted, or even have multiple authorized
releasers. This means that a package might have different signing keys that
people should trust, making the tooling even more complicated. So how does a
person know that when they attempt to install something and they get an invalid
signature warning that this one is "OK" to wipe but sometimes it's not? If they
go to PyPI to find out then we are back again at trusting the repository
implicitly. If they don't go to PyPI they are most likely to just hit whatever
lets them install, training them to just do what it takes to install and ignore
the warnings and prompts.

Finally this approach makes the assumption that that any particular developer
will have a stable machine on which the trust database can be stored. This is
often not true, especially in this day and age of ephemeral cloud servers where
new machines are started with a blank slate all throughout the day.


## What the Hell Are We Trusting Anyway?

The elephant in the room when talking about package signing is what exactly we
are trusting. For a repository like PyPI where everything is a free for all,
generally the only thing we can trust is that the person who made this release
is (according to PyPI) allowed to make releases. An important part of that
statement which is easy to ignore, is "according to PyPI".  Even if we wave our
hands and give ourselves the perfect way to transmit trust, as long as PyPI is
the authority over who owns a particular name then we **must** implicitly trust
PyPI to tell us who is allowed to release which packages.

All this said, we have not addressed whether it is *safe* to install this
package. I could register a malicious package called "hackme" and sign it using
any of the above methods and if you install it, even with the valid signature,
*you* have decided to accept the consequences of running my code. It's
important to remember that the only thing any of these systems are able to
verify is that the package you've fetched is the package you wanted,
nothing more.


## Everything is Terrible So What Do We Do?

Bluntly put, I don't know for sure. This isn't an already solved problem nor is
it an easy to solve one. I believe that whatever solution that is chosen is
going to have a lot of the problems listed above. My biggest hope is that we'll
get a solution where the end user has the relationship with the source of trust
and not the package author.


[1]: http://www.openpgp.org/
[2]: http://nacl.cr.yp.to/
[3]: https://pypi.python.org/
[4]: http://docs.python.org/2/distutils/packageindex.html#uploading-packages
[5]: http://www.debian.org/
[6]: https://www.redhat.com/
[7]: http://convergence.io/
