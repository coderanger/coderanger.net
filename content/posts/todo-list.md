---
title: My Todo List
date: 2016-11-29
published: false
---

With the US Thanksgiving holiday this past week, I decided to take some time and
write down all the projects that are still on my overall todo list. To lead off
with a disclaimer: this is not a promise I'll ever get to any of these or that
they will happen in any particular order. This is mostly for my own benefit but
hopefully it provides some value to others, if only documenting what still needs
fixing. Also this is just my own list and does not reflect the opinions of Chef
as a project or Chef Software as a company, and is neither in a specific order
nor exhaustive.

If any or all of these projects sound interesting to you and you would like to
see them happen sooner, maybe consider checking out my [job search page](/hire-me/)?

### Finish Porting Foodcritic Rules To Rubocop-Chef

This is in-progress now but still has a ways to go. You can see the current
status in the [rubocop-chef README](https://github.com/poise/rubocop-chef/).
The goal is to replace as much of Foodcritic as possible with Rubocop so that
we can get features like multiple message levels, autocorrect, and a unified
configuration file. It will eventually be integrated with the `cookstyle` project
as a one-stop-shop for opinions on how to write Chef cookbooks if you want to
use an existing style guide.

### Secrets Management Abstraction/API

I've talked about this a bunch and it's very close to the top of my list right
now. Basically I want to build a modular API for accessing [secrets](/talks/secrets/)
from Chef code so that cookbooks can be written to use "any" storage system (chef-vault,
Hashicorp Vault, S3/KMS, etc). The DSL elements will probably look very similar
to my [`citadel`](https://github.com/poise/citadel/) cookbook but with an internal
configuration system integrated with Chef and plugable backends.

### Deeper Integration Between Chef and HashiVault

I wrote up [a lot of words about this](/chef-and-vault/), but it is still vaporware.
Would be nice to spend some cycles making at least some parts of this exist.

### RAM Usage Analysis For `poise-profiler`

This has been sitting half-finished for a while now and needs to get over the
finish line. [`poise-profiler`](https://github.com/poise/poise-profiler/)
already provides a lot of timing data for Chef performance, I want to add memory
usage to that as well to see when a recipe or resource is allocating a large
amount of stuff (usually search results) and then not using it.

### Meta-Helper Library

A common stumbling block for new and experienced Chef users alike is adding
helper methods to Chef. Many of the old patterns in the ecosystem (like `Chef::Recipe.send(:include, ...)`)
are both dangerous and unnecessary. A library cookbook to provide an API to
declare various kinds of helper methods could both simplify the process and
help document the tradeoffs of the different kinds of helpers.

### Implement RFC 33

[Chef RFC 33](https://github.com/chef/chef-rfc/blob/master/rfc033-root-aliases.md)
adds support for a simplified folder structure for cookbooks with the aim of
making small wrapper cookbooks or other short one-offs feel less boiler-plate-y.
I implemented this long ago, but the branch bit-rotted before we could agree on
the RFC so it needs to be started from scratch by now.

### Implement RFC 36

[Chef RFC 36](https://github.com/chef/chef-rfc/blob/master/rfc036-dialects.md)
adds support for writing Chef recipes and some other Chef-related files in
languages other than Ruby (or JSON). Specifically I want to add things like
YAML and TOML support for attributes files and maybe some day Python/JavaScript
support for recipe code. Similar to 33, there are a few old implementation of
this but any new attempt will have to start over.

### Implement RFC 75

[Chef RFC 74](https://github.com/chef/chef-rfc/blob/master/rfc075-multi-policy.md)
adds support for assigning more than one policy to a node to allow use of the
Policyfile workflow in some situations where having a single compiled object is
problematic. I've now tried implementing this twice, only to find the approach
I used was fatally flawed, but I still think the feature is important and
should exist.

### Improve Test-Kitchen's Concurrent Mode

With the surge in Chef releases thanks to the new [monthly cadence](https://github.com/chef/chef-rfc/blob/master/rfc081-release-cadence.md),
CI build times have been rising rapidly. For most of my cookbooks I currently
run four test platforms across 18 Chef versions, and Travis only allows for
5 of those to run concurrently at most. Test Kitchen does support its own
concurrent execution mode to speed things up, but currently the output ends up
intermixed between the concurrent runs making it almost unreadable. For
interactive use this can be okay because you just repeat a failed command to
see the error message, but in a CI system this isn't an option. An improved
system could buffer the Test Kitchen output to files and then display it all
together when an instance completes the command. Not a ton of work, but anything
involving threads (which TK's concurrent mode is built on) is always deceptively
difficult.

### Use `docker exec` for Kitchen-Docker

Currently the `kitchen-docker` plugin launches sshd inside the container and
then uses the normal Test Kitchen SSH machinery to connect to the new instance.
This works okay, but it requires a fair bit of complexity around authentication
and `sudo` access that can sometimes make testing more difficult. In the years
since the plugin was first written, Docker has added their own remote
execution system in form of `docker exec`. Switching to this would allow for fewer
moving pieces and simplify the default `Dockerfile`.

### Improve Kitchen-Docker Build Performance

The default `Dockerfile` used by `kitchen-docker` is unfortunately slow to
build sometimes. Much of this is due to the creation of many intermediary
layers which could be collapsed together. I've already done a lot of this for
[my own use](https://github.com/poise/poise-boiler/blob/master/lib/poise_boiler/helpers/kitchen/Dockerfile.erb)
but it should be ported back out to the rest of the community.

### New Cookbook For Supervisord

The current `supervisord` cookbook is in need of a major upgrade and retrofit. This can
take advantage of the improved Python resources from `poise-python` and the
patterns built as part of the new `poise-monit` cookbook. This would also include
adding `supervisord` support to `poise-service`, allowing it to be used with
any cookbook based around that service abstraction.

### Resource-based Java Cookbook

The current Java cookbook has been a source of much frustration in the Chef
world. I've already got a lot of tools built for managing language runtimes
with Chef as part of the `poise-python/ruby/javascript` work, though undoubtedly
Java will bring its own unique complications.

### More Providers For Python and Ruby

The `poise-python` and `poise-ruby` cookbooks support multiple providers for
how to install their respective language runtimes, but they could both stand
to add some more options. On the Python side, source installs still need to be
added (refactored from the existing source install support for Ruby) and some
common PPAs like Deadsnakes should be included. For Ruby, the Brightbox Ruby
packages would be a good option for many.

### Improved SCL Handling On RHEL

The recent-ish 2.0 release of `poise-langauages` fixed support for Software
Collections on CentOS, but unfortunately broke many RHEL users. It follows the
official RedHat instructions to configure the RHSCL repositories through RedHat's
subscription system, but this flat out doesn't work for most cloud images and
development systems. Cross-installing the CentOS SCLs on RHEL seems like a reasonable
fix, as well as a more flexible `:rhscl` provider that works on at least some
more of the ways RHEL can be run.

### Finish Refactoring Halite Spec Helpers

As part of the Halite project, I built out a lot of helper methods for writing
Chef unit tests for complex cookbooks. Most of these are not specifically tied
to Halite so I've started splitting them out to a new gem: [`poise-spec`](https://github.com/poise/poise-spec).
These rest of the helpers need to be split out and then Halite's helper module
should be rewritten to use and extend `poise-spec`.

### Migrate The Chef Documentation

Now that we've started to clean up the Sphinx documentation for Chef, I want to
move the docs for Chef itself into Chef's code repository. This will make it
easier to require Chef changes to include doc updates in the same way as we
currently require tests, as well as making it easier to version the docs alongside
Chef. Some complexity will be needed to figure out how to integrate the Chef
docs with the rest of the Chef's product documentation so it can all be published
to `docs.chef.io` but I'm sure we can work through that.

### Integrate YARD and Sphinx

The current Chef docs are written using an excellent framework called Sphinx.
It has lots of tools and helpers for writing high-quality narrative documentation,
but most of it's reference documentation tools are aimed at the Python and C
worlds where Sphinx comes from originally. The gold standard for auto-extracted
code/reference documentation in the Ruby world is YARD, and we've already begun
adding more YARD comment markup throughout Chef and the broader ecosystem. The
missing link between them is a way to integrate YARD data into Sphinx docs
directly. A related project here is using YARD data to generate cookbook
READMEs like other Sphinx documents.

### Rewrite Poise Using New APIs

My [Poise helper library](https://github.com/poise/poise/) has aged reasonably
but enough has changed in Chef core to make a major upgrade look more and more
inviting. This will probably not happen until ~April 2017 (i.e. the Chef 13.0
release), when it will be more reasonable to drop support for Chef <12.5.
Notably the new resource property APIs will allow major refactoring of Poise's
helper methods and a lot fewer uses of `define_method`.

### Other Stuff

Outside of the Chef world I've got a few projects kicking around in my brain.
I'm a strong believer that Kubernetes is going to win the container orchestration
wars, but it currently has pretty much nothing for testing and static analysis.
Ditto on Terraform for infrastructure management (though there is a
`kitchen-terraform` plugin that looks very interesting for the future). Someone bringing
the same "teaching ops folks how to software" approach I've aimed at the Chef community
is probably going to be needed in the long run.

## tl;dr

I've got a big backlog of projects in the Chef world (and beyond) and if you want to help
make them happen you should [hire me](/hire-me/).
