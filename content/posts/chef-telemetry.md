---
title: Gathering Chef Usage Data
date: 2017-07-26
published: false
---

A [proposed Chef RFC](https://github.com/chef/chef-rfc/pull/269) currently
sitting in the review queue revolves around gathering anonymized usage information
about Chef and some of the Chef ecosystem tools. I think this proposal needs
some more eyeballs on it from the Chef community so hopefully this will encourage
some of you to weigh in by commenting on the pull request. Usual disclaimer on
time-sensitive posts, if you found this via Google some time in the future,
it might not apply anymore.

# Why gather user data?

As both a Chef maintainer and a cookbook developer, I have a big interest in this
user data. A big problem for Chef, as with almost all open-source projects, has
been that we know almost nothing about how the things we write actually get used.
We have some signaling from people asking questions on Slack or filing bug
reports, but this is both verr coarse-grained and ignores a huge majority of
users. This makes it very hard to know how to allocate time and resources, both
of which are in short supply (again, same as in any other open-source project,
none of this is unique to Chef).

Having some kind of automated data collection would give us a huge boost in
knowing what things are popular and should be given more attention, and which
were maybe failed experiments or are broken in some way we haven't been made
aware of.

As a concrete example, Test Kitchen supports a lot of driver plugins. There are
two Docker-based drivers, my `kitchen-docker` and Sean's `kitchen-dokken`. We've
been trying to steer people towards Dokken as a better user experience for
simple use cases, but as the maintainer of `kitchen-docker` I have no way to
judge how common the complex or advanced cases are, or even the rough distribution
of users for `docker` vs `dokken`. This makes it very hard to know what kinds
of things to support in each and (probably) leads to worse software for everyone.

# Why not to gather user data?

But all that said, this proposal makes me incredibly nervous. Like many in the
tech world, I have a nearly-instinctual anti-authority viewpoint and any form
of data collection feels like an intrusion. I've known and worked with the team
at Chef Software that would be responsible for this data collection system and
I trust them a great deal, but that is not a scalable approach to project
governance.

The main risk factor to users is the collected data leaking and being used to
do nefarious things. To keep ahead of that, we're planning to have all collected
data be public from the start, so at least no one ever has the false mindset that
it can be considered private (disclaimer: Chef Software is still researching
how this would interact with EU data protection laws and their privacy policy so
the specifics are still in flight). This doesn't entirely remove the risk of an
"oops" event. As pointed out in the pull request comments already, if we had
tried to gather data about which command line options were used, we could
accidentally pick up passwords that were mistyped and parsed as options. That
specific issue has been headed off at the pass, but something similar will likely
come up in the future. We are planning to hold all data as fully anonymized at
the point of collection, but de-anonymization techniques are always evolving and
while I can't point out any specific flaws in the proposed schema it's enough to
make me nervous. So in the end we will have to accept some level of passive risk
to users that an attacker could both find some data that we shouldn't expose (or
just misuse otherwise safe data like being able to see how many users of ChefDK
have an old version with a known-insecure version of OpenSSL because we all know
that will keep happening), and then either de-anonymize it or somehow use it as
part of an attack. This feels like an acceptable risk, but that's a personal and
subjective judgment so knowing how the community feels would help here.

As a secondary thing, there is almost always a PR storm any time an open-source
project brings up this topic. I am probably contributing to this, though hopefully
with enough positive to outweigh any trolls I bring in to the discussion. Still,
this could end up being a harm to users if we have to fight FUD for a while, so
that should be considered. All planning and development of this feature is being
done in the open, which also hopefully helps offset the "sky is falling" crowd.

# Opt In or Out

Any such system will be optional, but the more difficult question is if the
default should be true or false. A common refrain in these discussions is "just
make it opt-in", but that means either we need to find a way to explicitly
prompt for an opt-in, or just assume that almost no one will enable the feature.
Explicit prompts are difficult in a command-line world, but given the only other
option is a silent default of "collect data" with the opt-out only being
mentioned in documentation seems just as bad for users in the end. Either way
this is not a settled question and community input would be greatly appreciated.

# Prior Art

The proposed RFC covers this a bit but I wanted to dive in a bit more on some
ways other projects have handled this, mostly just to point out that this can
be done without the world ending (in part to remind myself of this).

Homebrew added similar tracking via Google Analytics last year, and definitely
had some growing pains with it initially. After the initial flurry of fixes to
what was being collected, it seems to be going okay, though the Homebrew team
has been somewhat gruff in dealing with complaints which might indicate that they
get a lot of flak behind the scenes.

Debian's PopCon, Ubuntu's Apport, and Fedora's Retrace projects all gather some
level of usage information about packages (the latter two only on crashes) and
have been mostly uncontroversial in my experience (other than complaints about
apport from Python devs because it does weird stuff to the load path but that's
neither here nor there). PopCon is mostly just for fun, but the error collection
has been cited as useful by a bunch of Ubuntu/Fedora projects.

Both Chrome and Firefox (and probably Safari but who knows with them) gather
anonymized usages statistics as well as crash reports, and I don't think I've
ever seen complaints about either. Firefox crash reports in particular, I know
several people that used to be on the team that managed that system and heard
from them frequently about how useful it was to the Firefox development team.

# Next Steps

Hopefully by now I've encouraged you to go drop us a line on [the pull request](https://github.com/chef/chef-rfc/pull/269),
we really do want to make sure we only move forward with this if it is in the
best interests of users and to do that we need to know what your interests are.
If anyone wants to provide feedback anonymously or has questions not answered here,
you can always reach me at <a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;">&#110;&#x6f;&#97;&#x68;&#x40;&#x63;&#111;&#100;&#101;&#x72;&#x61;&#x6e;&#x67;&#x65;&#114;&#46;&#110;&#x65;&#x74;</a>.

