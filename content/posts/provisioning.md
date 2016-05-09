---
title: The State of Chef Provisioning
date: 2016-05-09
---

Chef Provisioning (originally Chef Metal) is a collection of libraries and helpers to
use Chef to provision and manage infrastructure like virtual machines, servers,
load balancers and more. Chef applies a convergent and idempotent
model on server configuration management, so it felt very natural to extend
that up to the whole infrastructure.

Let me start out talking about the current state of Chef Provisioning by making
one thing really clear:

### Chef Provisioning Is Not Deprecated

That said, there has been significant change to the planned scope for it. The
original project was pitched, internally and externally, as a tool with a similar
scope and role to AWS CloudFormation, OpenStack Heat, and Hashicorp Terraform.
It would manage whole clusters, bringing up all the underlying cloud _stuff_ they need
to function.

Where we are today is that Chef Provisioning doesn't have the critical mass of
users to justify the massive resources required to bring it up to a point where
it would be Delightful to work with. To close the loop of the vicious cycle, few
people are using it because little time has been spent on polish. Community
contributions will still be accepted going forward, but at this time Chef
Software is unable devote the time and resources to lead future development.

Chef Software is still using Provisioning peripherally in some parts of Chef
Delivery, but my understanding is that efforts are under way to migrate those
off to other tools. Still, if your use case is substantially similar to a CI/CD
pipeline, what exists today might work well enough for your needs. That said, cloud
systems change often so be prepared to deal with future rot. If you
are interested in taking the lead in development or acting as a project
lieutenant, the Chef Software would love to talk about how to hand over the reins.

For most people, Chef Provisioning is unlikely to be a good choice for new
projects, and existing users outside of the aforementioned CD use case (or even
those inside that use case) should look towards other tools.

## How did we get here?

Before I go any further, it bears repeating that I do not work for Chef
Software, nor do I want to speak for those that do.

Chef Provisioning was pushed as a Big Thing™ for a while over the past year-ish.
Many people inside and outside the company saw it as the next logical step in
code-driven operations, and it felt like a great space to expand in to. I think
the main downfall of Provisioning was that building a generic infrastructure
management tool is really, really hard. Much harder than anyone though going in.
The core `machine` resource has been problematic enough on its own, when you
factor in the long tail of the different "value-add" services each cloud
provider offers (and the fact that none of them can agree on how to do anything)
things started getting a little out of control.

I think I can slightly bend my "don't speak for others" rule and say that
everyone inside Chef Software that had been evangelizing or developing Provisioning
is disappointed in this state of affairs, but Chef Software is a business and
sometimes you have to make unpopular choices.

## The Future

I do think the core concept of Chef Provisioning is still valid, and the
promise of unified workflows and tooling for CM vs. infra is still there. Chef
Software hasn't ruled out the possibility of being able to devote more resources
to the project at some point in the future, or perhaps someone else will start
something similar elsewhere.

For now though: I would recommend looking at either [Terraform](https://www.terraform.io/)
or if you are using AWS, [SparkleFormation](http://www.sparkleformation.io/).
