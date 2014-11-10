---
title: Chef Governance & Maintenance
date: 2014-11-10
---

In a way this is a follow-up to my earlier [post about the state of community
involvement in Chef](/chef-open-source/). Adam Jacob, the CTO of Chef
Software and current de facto lead of Chef as an overall software project, has
worked out a new governance and maintenance structure for Chef that I think
will help immensely with the issues I laid out in the other post.

This new policy is currently [under review as Chef
RFCs](https://github.com/opscode/chef-rfc/pull/58), which means if there is
anything you read here that you think is a bad idea, you can still
comment on the pull request. I am hoping we will discuss and approve these
RFCs in the **[November 13th developer meeting](http://timesched.pocoo.org/?date=2014-11-08&tz=pacific-standard-time!,eastern-standard-time,gb:london,au:sydney,de:berlin&range=540,600)**.
Any misinterpretations or paraphrasing are my own and should not be construed
as the opinions of Adam or Chef Software.

# I'm a busy Chef user; how will this affect me?

In general, it won't. If you are content to be only a user of Chef then
hopefully all you will notice is that Chef gets better faster.

# tl;dr

Chef will have an advisory board elected from both the userbase and maintainers
of Chef. Major components/projects within the Chef ecosystem will elect a
Lieutenant to manage them, with localized veto power. Maintainers (commiters)
can be approved by simple majority of existing Maintainers in their component.

# [Governance Policy](https://github.com/opscode/chef-rfc/blob/gov_maint/new/governance_policy.md)

The general idea of the governance policy is to ensure that users have a voice
in the long term planning of Chef as a project. The advisory board, named CBGB,
will help both project and company leadership to have a more balanced view
of life in the trenches, as it were. It holds no direct decision making power,
that will stay with the respective leadership teams, but it helps formalize the
relationship with the community.

The advisory board will have 12 members: four individual contributors, four
corporate contributors, three component Lieutenants, and the overall Project
Lead. Other than the Project Lead, all members are elected by the Maintainers
for one year terms. Any active contributor can run for the board in their
respective category.

# [Maintenance Policy](https://github.com/opscode/chef-rfc/blob/gov_maint/new/maintenance_policy.md)

As noted in earlier posts, almost all current Chef maintainers are employees of
Chef Software. The new maintenance policy helps to split those two roles apart.
It lays out a tree structure, with the Project Lead at the top, then a layer of
component or subsystem Lieutenants, and then the Maintainer teams.

Each layer resolves conflicts for the layer below them, so overall the
maintainers for a component operate by rough consensus with the Lieutenant
having veto/override authority if discussions drag on too long or have
become unproductive. The Project Lead, in turn, has veto power over the
Lieutenants.

Becoming a maintainer is a simple majority vote from other maintainers in the
component, and is handled by creating a pull request adding your name to the
appropriate section of the MAINTAINERS file. Maintainers get commit access to
the relevant project, and are expected to be available to assist users with
issues and to attend the [developer meetings every other Thursday](http://timesched.pocoo.org/?date=2014-11-08&tz=pacific-standard-time!,eastern-standard-time,gb:london,au:sydney,de:berlin&range=540,600) on IRC.

Each component team manages their own roadmap and release schedule (if
applicable), and the Lieutenant is responsible for publishing it and resolving
any issues with other components.

# How will these policies change over time?

Once ratified and accepted by the community, each of these policies will become
a [Chef RFC](https://github.com/opscode/chef-rfc) like any other. While some
sections are required for legal reasons, much of this will still be up for
discussion as the size and shape of the community continues to change. These
documents are not written lightly, but they should also be considered beta
quality until we see how well this structure works in practice.

There will also be future work in bringing other, similar RFCs in to line with
the maintenance policy such as the RFC editing process and the Community
Advocate roles. It is also hoped that over time more projects in the Chef
ecosystem can be brought in to this maintenance structure if they would like to.
