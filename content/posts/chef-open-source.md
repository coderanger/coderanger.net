---
title: Chef is not Open Source
date: 2014-07-01
hire_me: Many thanks to all those that reviewed drafts of this post.
---


Before I get started I want to say that I know this is a very important topic, especially to a few people at Chef Software (hereafter ChefInc). It is time to face this issue: Chef is not Open Source. I can't pinpoint exactly when this happened, but over the past few years there has been a definite shift away from the open source model.

## But the code is on GitHub

Yes, in the literal sense the code is open for viewing and modification, but the open source ethos is more than just that. It is about communities building software together.

## But I submitted a patch

Thank you for your contribution, but this issue is about the big picture. The original idea behind "the commons" was that by everyone putting in a little bit we could build software better and more sustainably. This isn't what is happening in the Chef community and ecosystem. We have ChefInc putting in a massive amount of time and money along with a few individuals, then a small handful of companies and even fewer individuals contributing through one project or another, and then the long tail of pure consumers.

## But all communities have more consumers than producers

Yes, and Chef's is just too far out of balance to be healthy. This single-producer ecosystem leads to a spiral of fewer contributors, thus proportionally more of the ecosystem is carried by those who remain. Unfortunately this seems to be a common outcome in corporate-backed open source projects as they try to transition towards profitability by embracing The Enterprise. Of the other communities I am active in, it seems like web development is the only arena with a good number of consistently healthy ecosystems. It is possible the operations world is new to this kind of community and still sees things from an end-user perspective, but I can only conjecture.

I know big companies have a bad rap with both B2B startups and the open source world, I want to be clear that I don't think the focus on them is a mistake in any way. I have enormous respect for everyone at ChefInc and if they think this is the best way to ensure a stable future for the company I will back them 100%. It just comes with trade-offs and I'm sorry to conclude that this is one of them.

## Well if not open source, what is Chef?

Chef is an excellent enterprise automation toolkit with a generous free product offering. And it turns out that's what most people want. I can probably name all of the people that are emotionally invested in Chef being a strong open source community (myself included) but we alone have not been enough to maintain the community ethos. But again, I don't think this is going to be the doom of Chef or ChefInc, the market has spoken and they are happy with a free product. Additionally having the code on GitHub gives a nice warm and fuzzy feeling that there is no vendor-lock-in, even though there is no other game in town.

You can see this trend as ChefInc gets worse and worse at building Chef in the open. How many of you know about the [Chef RFCs](https://github.com/opscode/chef-rfc)? While the process exists, it is used inconsistently at best, and discussion rarely moves beyond the few people involved in each pull request. The roadmap for Chef features is increasingly inscrutable, community-wide decisions are made either in private or behind open doors that are very well hidden, and community contributions have taken a nose dive.

# Case Study: Chef Support

As an example of the problems I'm talking about with producer/consumer ratios, let's look at how product support works for Chef. ChefInc offers paid support packages, but the vast majority of people won't use these. They also provide some excellent introductory training materials and classes, but these only get people started. What happens when they have questions after that?

## IRC

I'll start with my weapon of choice: IRC. I publish [nightly statistics](https://coderanger.net/irc/month.html) about the Chef IRC channels, but suffice to say that I provide the vast majority of customer support in this medium. The nearest ChefInc employee clocks in around one tenth of my output as best I can measure it, a pattern we will see repeated. I've tried to engage ChefInc about improving this but my emails have gone unanswered.

## StackOverflow

Probably the most popular way to get support for technical tools, the `chef` tag on StackOverflow is quite active. By far the most frequent responder there is Seth Vargo. Seth does work for ChefInc, but this is done entirely in his personal time and is not part of his job in any way. Again, after Seth the next nearest ChefInc employee trails by more than a factor of ten.

## Mailing List

Here fortunately things are a bit more balanced, with three of the top five repliers being ChefInc employees. I can't tell what proportion of these emails are written as part of their work hours, but none of the three are part of the customer support team so I can only guess it isn't much. This is also much more of a long tail than the others, with that top five covering only 15% of replies.

Overall there is a clear pattern of global Chef community support being provided by a tiny handful of people.

# Case Study: Contributions

## Chef Commits

Even though ChefInc does accept patches for Chef, the impact of this is quite low. By line count, only 4% of patches year-to-date have been from non-employees. 2013 didn't fare much better, only 7% non-employee contributions for the year. All told, the vast majority of Chef development is done by people employed to work on it.

## Chef Pushes

Beyond just commits, it is worth noting that Chef has effectively no non-employees with direct commit access. Going back to 2012 I can find only nine repository pushes from non-employees, coming from three people. Of those, seven were from a single person. Having the company serve as the sole gatekeeper to a project is entirely antithetical to an open source community.

## Chef-Server Contributions

Over the entire lifespan of the Erlang chef-server implementation I was only able to find a single patch from a non-employee, a one-line configuration fix. I'm sure this was understood as a risk factor when porting from Ruby to Erlang, but the effect was instantaneous and complete. This is likely not helped by the fact that the entire in-house development workflow for Erchef relies on numerous proprietary tools.

# What Do We Do Now?

I'll be honest, I don't know. I am extremely invested, financially and emotionally, in the health of the Chef ecosystem. I depend on it to pay my rent and it represents many years of my life. Unfortunately I can't say I see a way out of this. I know people within ChefInc really want to see this improve, and I certainly hope this post serves as a wakeup call to them that it should be a higher priority. I can't think of a community I've seen that has recovered from this situation, if anything they have sunk further into being free-but-commercial products. I hope ChefInc will find ways to improve community involvement and will be happy to continue talk to them about it, but I can no longer justify so many hours of unpaid labor to improve someone else's commercial product. As I said, I think the market has spoken and a quality free product suits it just fine.

# A Path Forward

If things are to improve I think it is clear on all fronts that things need to change. The will to evolve has to come from the community as a whole, but I have a few things that could be a starting point for the discussion:

1. Do more planning and design in the open. I would love to see the Chef RFCs used like Python's PEPs where major changes are written up as a formal proposal and then discussed on the chef-dev list. This should also include policy decisions like the recent Jira shut-down.
2. Create guidelines for becoming a commiter. There are many examples in the open source world, having a path towards more non-employee commiters will help.
3. Improve cookbook sharing. I've beaten the dead horse that is cookbook namespacing in to the ground plenty, but this is an active barrier to community participation for many people.
4. Encourage companies other than ChefInc to support development in the Chef ecosystem.
5. Investigate transferring Chef as a project to the Software Freedom Conservancy or similar.

None of these are a silver bullet, but together I think they could make a difference. I think a stronger and more diverse Chef community will build better tools. I think the open source model is a far more sustainable way to make software. I hope you all will join me.
