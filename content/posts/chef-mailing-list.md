---
title: The Chef Mailing List
date: 2015-11-03
hire_me: Hiring Chef engineers or tool developers? I'm looking for a new team! Check out my <a href="/looking-for-group/">Looking for Group</a> post for details.
---

Recently the Chef community mailing list was migrated to Discourse. This caused
some confusion and unhappiness in the community so I wanted to write up a
quick overview of the situation as I know it.

# Disclaimer

I do not work for Chef Software, nor was involved in most of the planning
stages for this migration. I do not represent the views of Chef Software and
am happy to correct any inaccuracies. Everything I did personally related to
this migration (including writing this) has been unpaid labor and was not
specifically requested by Chef Software. Nathen Harvey is, I think, still
working on a blog post for Chef Software but I didn't want to make the community
wait for that given how long it has been.

# Some History

In the deep, dark past of 2008, Adam Jacob and his co-founders at HJK Solutions
started an open-source project called Chef. In keeping with usual open-source
tradition they eventually created a mailing list for it. Being a scrappy young
company they grabbed a server, installed some mailing list software, and were
off to the races. Then some business happened. The larval HJK Solutions
metamorphosed into Opscode. Chef took off, and with it a community blossomed.

Unfortunately that original mailing list software survived basically unchanged
until last month. I don't know if it was the same physical server, but the
old `lists.opscode.com` has been carried around for quite a while. No one really
wanted to touch it as the config was on the bespoke side and the software, Sympa,
was a bit crotchety.

# Why Migrate?

I am personally amazed that so many thousands of people managed to successfully
navigate Sympa and sign up for the list. It had a terrible web interface,
almost un-searchable archives, and terrible moderation tools. To be fair to the
Sympa team, this is likely because Chef was running an unreleased version from
2007, which had never been upgraded because of a justified fear of breaking things.

In general the feeling from the Chef Software community team is that they didn't
want to deal with the ongoing hassle of running the mailing list and over the
years there were several attempts to migrate off to various other services.

# The RFC

In November of 2014 this was finally put down as a concrete plan in [Chef RFC
28](https://github.com/chef/chef-rfc/blob/master/rfc028-mailing-list-migration.md)
This was discussed at several of the weekly community meetings and eventually
accepted on November 13th. The original plan was to migrate to Google Groups,
though as we'll see that didn't quite pan out. Since then the document has been
updated to reflect the second attempt which used Discourse.

# The First Migration

In February 2015 the first major attempt to migrate the list happened. It was
well announced in advance, many conversion test runs had happened, and the
process for the swap-over was clear to the whole community. The goal was to get everything moved over
to Google Groups within a three hour window. Specifically this was going to use
the Groups feature within Google Apps For Your Domain so that the mailing list
addresses could stay the same. The migration was initially successful, with
everything copied over and ready to go. Then some issues were found. The Apps
mailing quota was counting every outbound copy of every message, so after only
a few emails we had hit the daily maximum and Google was holding all further
messages until the next quota reset. This was obviously going to be a problem,
so the decision was made to
roll back completely. MX records were updated back and we all continued on
Sympa. the rollback was handled smoothly and communicated well as to it happening,
if not exactly why.

After the rollback, there was more discussion in the weekly community meetings,
and Discourse was pointed out as another possible migration target. The RFC
was updated to reflect this.

# The Second Migration

At 1:54PM on October 13th we all received an email titled "Welcome to Discourse!".
This heralded a complete migration to a hosted Discourse instance,
`discourse.chef.io`. I can only relate second-hand as to the internal process
within Chef Software, but from discussions with Nathen my understanding is that
this was not announced within Chef Software either, and was being run as a
personal project between Nathen and the Discourse team directly. This was also
the day before the Chef Community Summit in Seattle, during which many people were away from their laptops for conference sessions or socializing with friends.  From what I can tell
reconstructing the history, the migration was almost entirely handled by the
Discourse staff team, not Chef Software. Things had been in motion for some time,
so the change on the 13th was requesting everyone pull their various
triggers to finalize the migration.

As to why the decision was made to go forward with Discourse, I can't say. It
had been pointed out as a potential option after the previous migration, but
it is unclear to what degree other options were considered and what the
process was. I'm hopeful the forthcoming Chef Software blog post will have
more information on this front.

# What Went Wrong

Discourse is first and foremost a discussion forum, but they do have enough
email integration to work as a mailing list too. However they have much less
experience with this use-case so I want to be clear that I do not hold them at
fault for the majority of these issues. The Discourse team has, in my opinion,
gone above and beyond in trying to help out and have happily run
with suggestions once they understood the use cases better.

The first and most notable problem was that when Discourse imported the Sympa
archive, it created accounts based on who had sent email to the list. This
had two notable consequences, people that had unsubscribed from the list at
some point in the past were suddenly getting emails again and anyone subscribed
but that had never sent an email was dropped from the user list. To try and
stem the tide of unhappy users, at ~8PM the Discourse staff globally disabled email
delivery for the whole instance. Around 10PM the staff team took the actual
subscription list from Sympa and re-enabled email delivery for anyone that had
actually been subscribed to Sympa at the time of the migration.

This still left anyone that had been subscribed but never participated in the
list in limbo; this was addressed later by Chef Software sending all such users an
email with information on how to sign up for Discourse. It also means that
anyone who was subscribed to only one of `chef` or `chef-dev` is now
subscribed to both (and the new Feedback category). I think a fix for this is
in progress but I don't know any details.

Initial confusion was magnified by the total lack of any announcements beforehand,
and the fact that getting access to one's Discourse account was somewhat
non-trivial in terms of complexity. This, combined with the various subscription
issues and general dislike of change by the Internet, led to an burst of
unhappy emails to the list(s).

Beyond those issues, many configuration problems were present in the initial
Discourse instance. While on my train from the airport I quickly asked Nathen
for admin permissions in Discourse and set to work fixing up the config. Many
of the default Discourse settings for things like email subject lines and
context make more sense for forum-ish communities and less so for mailing
lists. The fact that the site was initially branded "Chef Forums" magnified
this confusion. I fixed up the config to more closely align with user expectations
of a mailing list while trying to help keep things under control during the
flood of unhappy users.

Another major problem was that after the migration was completed, DNS for
`lists.opscode.com` was updated to point at an S3 bucket which redirected all
HTTP requests to `https://discourse.chef.io/`. This both broke all existing
links to the archives as well as removing any inbound mail delivery as S3 doesn't
relay port 25 for you. This was fixed (I think) the next day by reverting the
DNS change and setting the mail server on the lists box to forward to a gmail
inbox that Discourse polls for both new threads and replies. Unfortunately
at this time Discourse only allows one incoming address per category, so while
`chef@lists.opscode.com` works again, `chef@lists.chef.io` is non-functional.
The latter was never publicized and almost never used, so this is probably not
a big deal for the moment.

Incoming email still sees a notable delay as Discourse only polls for new
email every few minutes, as opposed to more traditional push-based mailing
list software which gets hooked in to the delivery process itself. It also
strips attachments, including PGP and SMIME signatures, and generally has
issues with email threading in a lot of clients.

# What Has Been Fixed

There are now several people with moderation permissions to help with site
operations. The site has been generally tweaked to be as close to a
mailing list as possible within what is currently doable within Discourse.
The Discourse project has made it very clear they would love improve to list-y
support and are happy to accept patches, though at this time I don't have anyone
offering to fund such work on my end and I am unaware of Chef Software working
on such patches. There is some contention [about if keeping list-y behavior is
even desirable](https://github.com/chef/mailing-list/issues/6), though I am firmly
in the camp that says it is.

The old archive has been restored for now, though long term I think the plan is
to work out a better way to redirect the archive links to the migrated Discourse
threads so we can actually decommission Sympa.

Users seem to be successfully using the list at this point, so I am happy to
call things stable for now. I've created an [FAQ thread](https://discourse.chef.io/t/welcome-to-the-chef-mailing-list/7070)
on Discourse to help explain things for new users, and will hopefully be able
to update that as new issues arise.

# How I Feel

I'm mad. I see this as a multi-faceted failure of the community. Communication
about this migration, before and after, faltered. This is doubly frustrating
given the excellent communication around the first migration attempt, showing
that it could have much so much smoother. After the initial wave of frustration
from users, there was a definite sentiment from some of "haters gonna hate",
which I feel masked legitimate issues in a way that was unnecessary. I feel like
the migration was rushed and many issues could have been resolved before the migration had there been
some kind of public beta test to gather UX feedback.

A mailing list is a resource often used as a last resort when a user is already
feeling frustrated, lost, or confused. It is absolutely vital that these kinds
of support channels (along with IRC, StackOverflow, etc) be welcoming and smooth.
I think Discourse can absolutely improve that over the old system, but I am
angry at level of disarray things were in. We need to ensure our community
protects our most vulnerable, and often that is people looking for help.

# The Future

As stated before, everything I've done so far has been unpaid labor out of a
sense of obligation to the Chef community. I've mostly run out of energy to
help further. I trust the Chef Software community team
will continue improving the site. I think things are pretty stable overall, the
site isn't everything I would have wanted, but it is in a position for the community
to move forward. I'll keep a close eye on things
as is my usual modus operandi, and am happy to do what I can with my remaining spoons.

# Questions?

If anyone has questions about any of this, what happened, why it happened, and
how to work with Discourse going forward, I am happy to answer to the best of
my ability you can find me at <a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;">&#110;&#x6f;&#97;&#x68;&#x40;&#x63;&#111;&#100;&#101;&#x72;&#x61;&#x6e;&#x67;&#x65;&#114;&#46;&#110;&#x65;&#x74;</a>
or on pretty much any Chef community resource as `coderanger`.
