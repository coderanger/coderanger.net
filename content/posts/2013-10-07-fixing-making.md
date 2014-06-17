[Making things is hard](/2013/09/making/), and I think I can make it better.
Over the past 12-18 months I've found myself drawn to what I think is a void in
the current tech landscape. As I said in my last post, I want to see tech in
general and application/site development in particular opened up to everyone. To
get there we need to drastically reduce the barriers to entry. I've also felt
more of a pull towards the community side of the equation. Fixing and improving
our software is definitely a piece of the puzzle, but I've come to believe that
community building and evangelism are just as important.

# Documentation

Most of the tools that make up modern application stacks are fairly well
documented themselves. You can load up the Postgres docs and deploy a simple
server without too much fuss. Moving from that to what I would call "first class"
infrastructure takes a lot longer to sort out. Replication? Automated failover?
Performance monitoring? Automated scaling? Clear, concise, and regularly updated
documentation on these tasks would be a massive boon to people just starting
out in the world of the cloud.

This kind of documentation also serves to show where the pain points are. As I
iterate over them, my goal is to remove as many steps as possible. Some of this
can be through sane defaults, some through outright bug fixes, and many through
continued evolution of standards for system interaction between components.

# Community Building

The operations community is a similarly fragmented landscape. There are vibrant
and helpful communities around each individual tool, Django, Postgres, Heroku,
Nginx, etc, but as a new user coming in to #django and asking how to deploy and
operate an application you will at best get a few personal opinions of tools and
services those community members have used. There are a few spaces that do cater
to this more holistic view of the world, my favorite example being the
DevOpsDays conferences, but they are often ephemeral. I want to see a nexus
point for smart people to learn and share about these topics 24/7. This not only
helps those of us already a part of the cloud development/operations world, it
also provides a starting point for the massive influx of new folks I hope we can
bring in to the fold.

# Composable Infrastructure

To borrow a description from the inimitable [Jim Meyer](https://twitter.com/purp),
I want to see application operations more as a set of LEGO bricks bricks than
the current morass of discrete systems we have today. The evolution and relative
accessibility of PaaS services and other hosted offerings for everything from
databases to load balancers has certainly helped us down this road. The darker
side of these services is that they often have very hard edges about what they
will and won't support. If you are using a hosted SQL database and want to change
a few of the tuning parameters to better match your application, you need to
first rebuild the entire hosted offering and _then_ you can make your changes.
A similar thing happens if you want to migrate off a PaaS and on to your own to
your own systems.

The model almost all of the current generation of configuration management tools
have settled in to is (mostly) declarative models that idempotently update the
state of something on the system. My weapon of choice is Chef, but the same
structure is pretty universal with Puppet, Salt, Ansible, etc. All these systems
come with a lot of low-level LEGO blocks, packages, config files, services. The
next step is to use these to build larger abstractions, a Python installation,
an Apache vhost, a Postgres database. This process repeats until you have the
true building blocks we all want.

Compare the operations ecosystem to the web development world, where we have built
fantastic abstraction layers up over the years, from CGI, to WSGI, to URL
routers, to HTML renderers. The author of a piece of code can focus on just the
level of complexity that solves their problem and not worry as much about
everything above and below it. I want to see this transition in the ops world,
where people can each focus on the pieces of the system that interest them most
while we all take advantage of the results.

-----

I think this is one of the most important tasks facing us as an industry, and
I want to ensure that making things only becomes more awesome. If this is
something your company is interested in and you are hiring,
<a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;?subject=Work with us">get in touch</a>.
