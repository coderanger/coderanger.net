---
title: The Agents Are Coming
date: 2017-02-13
hire_me: Liked this post? Check out my discussion of <a href="/ambulance-drones/">the thing that made me take consumer drone technology seriously</a>.
---

# No, not Hugo Weaving

Over the past five years, agent programs have been rising in both importance
and ubiquity. Apple mostly kicked things off for the modern generation of agents
with the release of Siri in 2011. Siri was a voice-based personal assistant,
able to send text messages, update calendars, and tell you the weather. From
this relatively-primitive nucleus, a whole industry has sprung up. While there
are several major archetypes of agents we'll talk about below, they all share
a few major characteristics. The first is a generally conversational nature,
you talk to them either via voice or text but in a way you would talk to a human.
This is usually far from a perfect simulacrum, but Siri interactions are a far cry
from text adventure prompts or command line interfaces. The second unifying
feature is some concept of context. Again taking Siri as an example, it knows
where you are when you ask for the weather and so "does the right thing". The
third trait is a bit more fuzzy, but most of the current agent developers have
tried to give their creations some kind of personality. All together, these
ideas bring together a broad swath of AI research and development and have fueled
an explosion in agent systems of all types.

# Personal Voice Assistants

While Siri is probably the most high profile, all of the tech titans have
thrown their hat in the ring of "personal voice assistants" in one way or
another. On the heels of Apple's Siri has been Amazon's Alexa (or Echo depending
on your wake-word). Google also has the somewhat less popular (and less-humanly
named) Google Assistant and Microsoft has Cortana, but Siri and Alexa have mostly
defined this battlefield with all others playing catch-up. A split has emerged
from those two, with Siri "living" in phones (and later, laptops) while Alexa
is based in mostly-unmoving physical objects in a home (Echo, Dot, etc).
Google has moved to offer both options for their Assistant, but this design
schism has certainly polarized much of the marketing of their respective camps,
if not the design of the software. While some third-party and open-source
teams have tried to offer additional options here (the [Jasper](https://jasperproject.github.io/)
project probably being the most complete though I'm personally still hoping
[Jibo](https://www.jibo.com/) manages to succeed), for the most part the big four
companies have this on lock-down. The value of a personal assistant is very
related to pervasive access and proximity, and each of the existing phone and
computer OS makers has made it clear they have no interest in allowing options
other than their own (for reasons that will become clear below).

# Business Assistants

With the personal assistant market mostly inaccessible, many companies wanting
to cash in on this space have turned to businesses as an untapped market. Rather
than integrating with just one person, these agents generally aim to fulfill the
same role as a secretary or office manager; scheduling meetings, sending out
team-wide updates, and other relatively simple-but-frequently-annoying duties.
The two main players I see a lot in this space are Clara from [Clara Labs](https://claralabs.com/)
and Amy from [X.ai](https://x.ai/) (and yes, feminine names/traits for
subservient agents is apparently just a given at this point), but they are
proliferating as fast as VCs can write checks it seems. My guess is that travel
management will be next on the list for many of these companies, but time will
tell. Unfortunately one big problem with a lot of these agents is the open
secret that much of their AI is heavily "supervised" by human "trainers". The
labor politics of AI and mechanization are complex to say the least, but further
development here is certainly likely to have an impact on the polarization of
tech industry workforces, with more of the few remaining entry level jobs being
moved into some mix of agent AI and "virtual remote assistant" services.

# Chat Bots

Focused more on consumer-facing systems, chat bots have exploded even more recently
than the other two. The first wave was the now-ubiquitous "customer support chat"
windows on websites. While I'm sure some of these originally used human reps just
as they would in a call-center, more and more are moving to either "AI assisted"
or straight-up agent AI systems. Nina from Nuance (side note: Nuance has been
involved in almost every company I've listed here in one way other another, they
are probably one of the most important AI companies you've never heard of), is
one of the most visible but almost every customer support firm has added agent
tools to their offering.

More recently we've seen several major chat systems build frameworks for
companies to interact with customers/users via chat bots. Facebook has been
among the most visible, promoting all manner of companies as bot partners.
Slack has gone even further, not just promoting bot makers but building a
custom venture fund to try and attract people towards integrating with Slack.
These kinds of chat bots are definitely the least agent-y of what we've seen,
but it seems clear that there will be some convergent evolution as things move
forward. Rather than acting on the behalf of the user, the bots are projections
of a company or service, but beyond that the interaction structure is very
similar.

# The Near Future

Where are we going from here? I think there are three main areas we are going
to see growth in over the short term. The first is improvements in the
contextual awareness of agents. The simplest example is that no current voice
agent can distinguish multiple voices. The uses for this kind of data would be
huge, like saying "play my favorite song" to Alexa or having Siri not pick up
on [commands from a TV show](http://www.theverge.com/2017/1/7/14200210/amazon-alexa-tech-news-anchor-order-dollhouse).
More context into our lives will allow more reactive
behavior, potentially even moving into proactive systems like knowing to pause
Spotify on my phone and start it on my laptop or Echo when I walk into my house.

Next, I think we'll see a major increase in the reach of agents. Right now Siri
can turn my lights on and off, and set calendar items or reminders, but not
really a whole lot of real "weight". Alexa's shopping integration offers a
broader grasp, but we are still a long way from connecting an agent to my
Paypal account, or my (hopefully soon to be self-driving) car, or even my email.
The more systems an agent is hooked in to, the more potential to cause problems.
It will take a lot of time and slow build-up, but seems inevitable that reach
will grow over time.

Right now all of these agents really only "exist" while you're interacting with
them. They have no permanent existence, and so can't take action outside of a
specific call-and-response prompt. Of all the limitations on current agent tools,
this seems this most restrictive. There is no way to tell my Siri to talk to
someone else's Siri to schedule a meeting, or for me to authorize my Alexa to
let someone else stream to my TV. The first inklings of this are starting to
appear with push notifications in the same way as for phone apps, but this is
only the beginning. For a possible end-game view I turn to a story from Vint Cerf
during a talk he gave on the future of the internet in 2015. He talked about how
he has security cameras and motion detectors throughout his home already, something
which requires the utmost in information security for hopefully obvious reasons.
But if there was a fire, would you want the fire department to get access to that
data? If they could immediately know where everyone in the house is and what
situation they are in, it is a virtual certainty that lives will be saved. At
the same time no reasonable (I think I can say this with full bipartisan agreement)
person wants to give a government agency a live video feed of their home. So
who or what should make the call to enable or disable the data sharing? This is
a role that a more autonomous agent system could fill, though only time will
tell if we ever get this far.

Beyond the technical improvements, I think the biggest story for agents in the
coming years will be their commercialization. Telegram already refers to their
agent directory as a "store" (though for now I think all of them are gratis).
Apple has recently moved to allow limited third-party development in Siri, and
Amazon has been pushing hard on their Alexa APIs. Just as phone apps led to the
gold rush that was the iOS and Android app stores, I think we will see a major
push towards app-ification of agents or agent functionality/integrations.

# The Further Future?

Too move even further into speculation tinged by sci-fi, I think (and hope)
there is a possibility of agent systems becoming more of a proxy of ourselves
in digital space. We're already seeing lots of growth in tools for "attention
modeling" (eg. Facebook timeline) to help manage the massive influx of information
that is part of modern life. I think over time this might fuse with the other
functions mentioned above to form a more complete virtual projection. This also
harkens back to the view of personal agents as replacing a a human assistant or
secretary, but as models of attention and trust get better these avatars can
accomplish more by interacting with each other instead of humans. If I ask my
agent to find a good time for dinner with a friend, it can just do that rather
than the "well what time is good for you" dance. These kinds of avatars have
been such a common trope in science fiction that it is hard to even imagine
them without taking fairly direct cues from specific stories or instances, but
as both our rate of data ingestion and interconnectedness show no sign of slowing,
something along these lines seems inevitable.

With that said, a lot will have to change in our social and legal landscape to
make this truly viable. Already today we're beginning to see some backlash
against poorly secured hosted services. While Siri has mostly been limited to
living in a specific phone, Alexa and Google Assistant are built from the
ground up as hosted services like GMail or Amazon Video. These kinds of services
have already firmly blurred the line between expectations of privacy versus
what is actually a personal space, and things are only likely to get worse.
Giving an agent access to all your personal information, habits, and data to
allow it to better help you is going to be a powerful motivator but with things
like the iCloud photo thefts or NSL data disclosures still fresh in many minds
(okay, maybe more the former than the latter but I can dream) I hope to see
a push for legal protections for this kind of system or for hosted/shared services
more broadly as they do truly become an extension of ourselves.

# Why?

So why has all of the this been happening? Why do I think this field is important
enough to spend the time to write several thousand words on it? Because if done
well I think agent systems will open up whole new worlds of interaction in the
same way that the jump from teletype command line interfaces to GUIs and mice
did for workstations, or that touchscreens did for phones. We are fundamentally
social creatures, and interacting with the world through language is much more
intuitive than the forced abstractions we've created in the computing world like
menu bars and double clicking. Agents, and especially voice agents offer a
way to streamline the daily lives of an almost uncountable number of people
around the world.
