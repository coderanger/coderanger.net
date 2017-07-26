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

As both a Chef maintainer and a cookbook developer, I have an interest in this
user data. A big problem for Chef, as with almost all open-source projects, has
been that we know almost nothing about how the things we write actually get used.
We have some signaling from people asking questions on Slack or filing bug
reports, but this is both very coarse-grained and ignores a huge majority of
users. This makes it very hard to know how to allocate time and resources, both
of which are in short supply (again, same as in any other open-source project,
none of this is unique to Chef).

Having some kind of automated data collection would give us a huge boost in
knowing what things are popular and should be given more attention, and which
were maybe failed experiments or are broken in some way we haven't been made
aware of. This has happened many times over the years, we maintainers assuming
something was no longer used, and finding out only after the release that we were
wrong ([obligatory xkcd](https://xkcd.com/1172/)).

As a concrete example, Test Kitchen supports a lot of driver plugins. There are
two Docker-based drivers, my `kitchen-docker` and Sean's `kitchen-dokken`. We've
been trying to steer people towards Dokken as a better user experience for
simple use cases, but as the maintainer of `kitchen-docker` I have no way to
judge how common the complex or advanced cases are, or even the rough distribution
of users for `docker` vs `dokken`. This makes it very hard to know what kinds
of things to support in each and (probably) leads to worse software for everyone.

# Why not to gather user data?

The main reason to not gather user data is the risk of said data ending up
used for nefarious purposes. A simple case might be someone finding a password
that was incorrectly pasted in the wrong section of a config file, but more subtle
issues can arise like searching for users with old versions of ChefDK which have
a known vulnerability in their OpenSSL. To counter this we have two main lines of defense:
first is that all data is stored anonymously with a session identifier reset
every ten minutes. Second is that we plan to make sure all data is public from
the start, so we don't have to wait for an inevitable leak to realize there is
a problem with the data.

Anonymous data is never perfect though, and the rise in public data sets has lead
to new advances in de-anonymization. We will do our best to keep on top things,
but there will always be some passive risk. Therefore any data collection
must be optional with both per-user and per-project configuration, but more on that
below. Also it is worth restating here that only workstation commands are being
considered for this. `chef-client`, `chef-solo`, and the whole of Chef Server
do not and will not collect data of any kind.

As a secondary thing, there is almost always a PR storm any time an open-source
project brings up this topic. I am probably contributing to this, though hopefully
with enough positive to outweigh any trolls I bring in to the discussion. Still,
this could end up being a harm to users if we have to fight FUD for a while, so
that should be considered. All planning and development of this feature is being
done in the open, which also hopefully helps offset the "sky is falling" crowd.

# Opt In or Out

As mentioned above, all data collection will be 100% optional, but that brings
up the question of how to control it. We will need to pick a default yes/no, as
well as how to tell the user about this whole thing.

Being silently disabled by default is effectively a non-option since we would get
so little data as to not be worth the effort to build the whole system, and
being silently enabled by default would (I think rightly) be viewed by many users
as a breach of trust and overstepping our bounds as a project.

I think the best approach is a middle ground, off by default, but the first time
you run any instrumented command it asks if you want to allow telemetry with a
default of "yes" if you hammer on the enter key. This will mean we don't get
data from TTY-less systems like CI servers, but is otherwise a balance between
user expectations and data quality. The opt-out will always be available afterwards
via a command like `chef telemetry disable` or something, or you can manually
touch the `.chef/no_telemetry` file (which can be checked in to source control to
permanently disable things for a project).

We would love to [hear from you](https://github.com/chef/chef-rfc/pull/269) if
you have thoughts on this though.

# Prior Art

The proposed RFC covers this a bit but I wanted to dive in a bit more on some
ways other projects have handled this, mostly just to point out that this can
be done without the world ending.

Both Chrome and Firefox (and probably Safari but who knows with them) gather
anonymized usages statistics as well as crash reports, and I don't think I've
ever seen complaints about either. Firefox crash reports in particular, I know
several people that used to be on the team that managed that system and heard
from them frequently about how useful it was to the Firefox development team.

Debian's PopCon, Ubuntu's Apport, and Fedora's Retrace projects all gather some
level of usage information about packages (the latter two only on crashes) and
have been mostly uncontroversial in my experience (other than complaints about
apport from Python devs because it does weird stuff to the load path but that's
neither here nor there). PopCon is mostly just for fun, but the error collection
has been cited as useful by a bunch of Ubuntu/Fedora projects.

Homebrew added similar tracking via Google Analytics last year, and definitely
had some growing pains with it initially. After the initial flurry of fixes to
what was being collected, it seems to be going okay, though the Homebrew team
has been somewhat gruff in dealing with complaints which might indicate that they
get a lot of flak behind the scenes.

Overall it seems like a lot of bigger projects add this kind of tracking to
little fanfare, especially desktop applications (like ChefDK).

# Next Steps

Hopefully by now I've encouraged you to go [drop us a line on the pull request](https://github.com/chef/chef-rfc/pull/269).
We really do want to make sure we only move forward with this if it is in the
best interests of users and to do that we need to know what your interests are.
If anyone wants to provide feedback anonymously or has questions not answered here,
you can always reach me at <a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;">&#110;&#x6f;&#97;&#x68;&#x40;&#x63;&#111;&#100;&#101;&#x72;&#x61;&#x6e;&#x67;&#x65;&#114;&#46;&#110;&#x65;&#x74;</a>.

