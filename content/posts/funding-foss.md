---
title: Funding FOSS
date: 2015-06-28
published: false
---

This past week I attended [Open Source Bridge
2015](http://opensourcebridge.org/) to speak about [how the Internet
works](/talks/internet/). A common topic both in the talks and the hallway track
was how to improve the funding of open source software or, put more generally,
how to ensure that the software ecosystem we enjoy today is sustainable. I
wanted to summarize some of my feelings on the topic as this is something I care
about deeply both personally and professionally.

# What is a society?

Before I talk about FOSS, I want to take a bit of a detour. At its most basic,
a society is many individuals working together for their collective benefit.
As societies progressed from small family clans to agricultural collectives to
city states and nations, we have seen an escalation of the Commons. Shared
granaries meant no one farmer was at risk of dying from a random crop failure.
Improvements in technology due to specialization allowed others to specialize
themselves. In just a few hundred generations, collectivism has allowed us to
go from nomadic apes to the vast civilization you see today.

# What is the Commons?

The Commons is an abstraction of collectivism. There exists some pool of work,
talent, and resources that everyone puts in to, and then everyone gets back out
some benefit hopefully in excess of what they put in. In a modern context, an
example would be taxes. Everyone (or almost everyone) pays in, and in return
we all get roads to facilitate commerce, schools to ensure an educated
population (and therefore workforce), etc.

# Why does Open Source matter?

Open source software is a new, and very powerful, branch of the Commons. We have
created an amazingly powerful collection of tools and techniques which now power
the vast majority of new businesses. Even old holdouts like Microsoft have
recently started to try to engage the open source community, to tap our
willingness to build the Commons. I don't think it is an overstatement to say
that without our collective investment in this shared platform, we would not
have nearly the same rate of technological development as we have today. Beyond
the tools themselves, within a rounding error the Internet itself is a
manifestation of all our communities. There are some places using Microsoft's
IIS here or Oracle's database there, and many core implementations of things
like BGP are proprietary, but the same community aesthetic powers groups like
the [IETF](https://www.ietf.org/) and [W3C](https://www.ietf.org/).

# Where did it all go wrong?

In the early days of the open source movement there were relatively few projects
and in general most people using a project were also contributing back to it in
some way. Both of these have changed by likely uncountable orders of magnitude.

Contributing to a project like PostgreSQL or Python has a huge multiplier effect.
So many people use these projects that only a small proportion of users need to
contribute back to keep everything moving forward at an acceptable pace. Or to
be more economical about it, the return on investment from a contribution was
shockingly high. As we have moved to more and more niche tools, it becomes
harder to justify the time investment to become a contributor. "Scratching
your own itch" is still a powerful motivator, but that alone is difficult to
build an ecosystem on.

The other problem is the growing imbalance between producers and consumers. In
the past, these were roughly in balance. Everyone put time and effort in to the
Commons and everyone reaped the benefits. These days, very few people put in
that effort and the vast majority simply benefit from those that do. This
imbalance has become so ingrained that for a company to re-pay (in either time or
money) even a small fraction of the value they derive from the Commons is almost
unthinkable.

## Bonus Concern: Corporate communities and DevOps

Many of the projects we look to as examples of the best outcomes for open source
were built as communities first. Even those that did come out of a company, like
Django from the Lawrence Journal World, the community formed around the project
and not the company. There is a long history of companies participating by
either by donating resources or hiring contributors, especially in projects
like the Linux kernel, but this has always been a relationship subordinate to
the community as a whole. The operations software world has seen an explosion of
single-company, often VC-backed projects where the company comes first and builds
a community around itself. This has worked in some cases, but it is notable as
a departure from the models we used to get here.

# Where are we going

## and why am I in this handbasket?

The tech sector and the glut of VC money that keeps it afloat is addicted to
free (as in beer) software. It is flat-out assumed that a company can launch a
product without paying a dime (again, either in time or money) in software
costs. The biggest software expense for your average startup will be either
buying SublimeText or their GitHub subscription. In and of itself, this reliance
on everything being free at first is not a problem. The issue is that no one
ever wants to pay the piper. Companies that succeed do not pay forward the
"loan" they got from the Commons. We see lots of companies launching open source
projects because they want to "give back", but we've all felt that pang of dread
when we realize the project is really a marketing stunt in disguise. Some of
these projects are really beneficial to the community and I'm glad they exist,
but even with that the balance between value derived from the Commons and value
put in to it is woefully lopsided.

# How do we make things better?

I have spent the last few years chasing the dragon of professional open source
contribution, but it has been a hard battle. There are a few options available
today for people that want to try them, and some that could work in the
near-term future.

## Kickstarter, Patreon, and other ad-hoc sponsorship

I did run a Kickstarter myself, and between that and an associated donation I've
been able to fund the last six months of my work. That said, I really don't
recommend this option to others. Fund-raising (or advertising a Kickstarter
campaign) is hugely emotionally draining, and the mental burden of "I've already
sold these features to people" is considerable. Patreon is at least an ongoing
donation, as opposed to a one-time cash infusion, but I've not yet seen anyone
receive even close to a living wage on there or any similar service. Even if you
do manage to raise a good amount of money, 10% immediately vanishes to fees. If
you are far more outgoing and comfortable with self-promotion than I am, this
might be a path for you.

## Hiring contributors

Another common option is to try to find a company that works on open source
tools and get a job there. If you don't have ties to a specific community and
just prefer working on open source code, this is probably viable given the
number of companies with open source products either in part or in full. With
specific communities this can be harder though, especially more niche tools.
That said, some companies like Rackspace and HP have done great work hiring
existing contributors for projects they want to see improved, and generally
getting out of their way.

## Patronage

This is very similar to hiring people, but I like the overall mental model of it
better. When hiring an employee, there is an implicit assumption that you will
do work as needed and directed by the company and the employee gives up most of
their rights over the work in exchange for a paycheck. This is summarized by
"work for hire". I want to burn it down.

I think a more stable model for "I want to pay someone to make open source
better" is that of Renaissance era patronage. It was considered socially
"required" that a rich person or family (which is roughly comparable to a
company in modern terms) would have one or more artists who they would support.
These artists would make great art to show off to the patron's friends and such.
I would love to see a world where every successful tech company is simply
expected to have a bunch of open source developers on staff not because it
benefits the company's products but just because it enriches the world. Stripe
is a great example of this model, with their open source grant program. Finding
others willing to put down the resources to be a patron has been difficult.

## Foundations and grants

A solid model used in other arenas is big foundations collecting money and then
handing out grants. We do have a lot of foundations in the open source world,
and some have tried to run grant programs. The problem has generally been
awareness and volume. The PSF grants program has gone mostly unknown, and most
software foundations can't fund more than a handful of full-time developers.
This is a good step, but not enough to make a dent in the needs of the
community.

This is been successful at small scales with mini-foundations like
[RubyTogether](https://rubytogether.org/) and [Node Security](https://nodesecurity.io/).
These mini-foundations generally find ongoing corporate sponsors and fund a
small number of full time developers. Scaling up to either bigger teams or
less niche tools is a stumbling block, but they are still a powerful story.

One avenue to improve this would be to hire professional fund-raisers. The
non-profit and NGO world has lots of full time workers that focus on raising
money for the foundation. As long as they bring in more than they cost, this is
still a beneficial arrangement.

Grants by companies have also had some level of success. I am not a huge fan of
Google's [Summer of Code](https://developers.google.com/open-source/gsoc/) or
[Highly Open Participation](https://developers.google.com/open-source/ghop/)
projects, but they do show the viability of corporate grants as a model. Bug
bounties are also a small version of this, though rarely big enough to claim to
actually support development overall.

## National Endowment for Engineering

Many governments use tax money to support science and art. In the US we have the
[NEA](http://arts.gov/), [NSF](http://www.nsf.gov/), [NIH](http://www.nih.gov/),
and more. These fund work to enrich society through grants and donations. I
would love to see a similar structure in place for technology or engineering in
general. Where these grant programs do exist, they are often impenetrable to
non-university applicants so that would also be something to see improved.

This is probably the only option here that can make a difference in the long
term. While I would love to see the others happen, I find it hard to imagine a
world in which they are pervasive enough to continue the current rate of growth
that has been powered by untold hours of unpaid labor. Unfortunately this
solution is also the one I feel the least equipped to help move forward on.

## Universal Basic Income

An end game solution: provide a basic standard of living so people that want
to dedicate themselves to enriching society can do so without putting their own
needs in jeopardy. [UBI](https://en.wikipedia.org/wiki/Basic_income) is, to put
it mildly, a contentious issue. Small pilot programs in many places around the
world have had promising results, but we don't have any clear path to serious
adoption right now. Beyond the logistical challenges, discussing any
non-capitalist system is often politically unfeasible in most governments. My
thoughts on a post-capitalism world are worth a whole post on their own, but
this is something we should all keep in mind as we displace more and more jobs
via automation.

# What do we do now?

Unfortunately many of these options are unhelpful for one individual trying
to find a way to work on software and communities they care about. Ad-hoc
solutions like "spend one day a week on personal projects" do help, and
management teams at companies successful enough to afford it can help to
encourage contribution. In the end though, it is a bleak landscape right now.
Open source burnout is being discussed more openly, which gives me hope that
we are working towards reducing it, but for now the only real option is to
try to take care of yourself and hope that some day all of this will be viable.

<style>
#and-why-am-i-in-this-handbasket { margin-top: 0; }
</style>
