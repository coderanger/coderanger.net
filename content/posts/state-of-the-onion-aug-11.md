---
title: State of the Onion for August 11
date: 2015-08-11
---

It has been a few months since [my last status update](/state-of-the-onion-may-26/)
and things are coming along nicely. As before I would like to again thank all my
sponsors and supporters for making this work possible!

## Support Cookbooks

Both Poise and Halite have seen feature releases. Mostly this has been support
for Chef 12.4+ as well as some minor fixes and helpers. Lots of good stuff,
but mostly relevant to me as the author of all this.

## Application Cookbooks

The application cookbooks have moved forward quite a bit. The four core
cookbooks ([`application`](https://github.com/poise/application),
[`app_git`](https://github.com/poise/application_git),
[`app_ruby`](https://github.com/poise/application_ruby),
[`app_python`](https://github.com/poise/application_python)) are all
minimally feature complete. This means that they support all the resources I
want before release, but some of those resources are intentionally minimalistic.
With service resources like `thin` and `gunicorn` they support the most common
options like `port` as resource properties, with creating a configuration file as
a fall-back for less frequently used options. I could use help in determining
which options for each tool are common enough to warrant being exposed directly
in the DSL.

Example recipes are available covering four of the most common web frameworks:

* [Sinatra](https://github.com/poise/application_ruby/blob/master/test/cookbooks/application_ruby_test/recipes/sinatra.rb)
* [Rails](https://github.com/poise/application_ruby/blob/master/test/cookbooks/application_ruby_test/recipes/rails.rb)
* [Flask](https://github.com/poise/application_python/blob/master/test/cookbooks/application_python_test/recipes/flask.rb)
* [Django](https://github.com/poise/application_python/blob/master/test/cookbooks/application_python_test/recipes/django.rb)

## Language Cookbooks

Both [`poise-python`](https://github.com/poise/poise-python) and
[`poise-ruby`](https://github.com/poise/poise-ruby) are feature complete and
ready for release. They support installing the Ruby or Python runtime from a
variety of sources, handle command execution for the language, and have
resources to manage language-specific package installs.

A lot of the shared code between them as also been refactored to a set of shared
mixins in a new `poise-languages` cookbook.

## What's Next

Over the next few days I'm going to continue to improve the documentation for
all these cookbooks. Reference documentation for all the new resources is in
places already, but the introductory guides need more work as do porting guides
for those upgrading from the current versions of the cookbooks.

I want to get all the previously mentioned cookbooks shipped so people can start
using them before I move on to creating new ones. I'm hopeful that shortly after
the big `x.0.0` releases there will be a flurry of smaller feature releases as
people point out options and patterns common enough to be promoted to full DSL
support instead of being in configuration files.

After that the next big application type on my list is server-side JavaScript,
and then smaller helpers for Java, Go, and Erlang. Also on the smaller side of
things is some exploratory work on a general-purpose service discovery API for
Chef recipes.

## tl;dr

The application stacks for Ruby and Python will be released very soon. If you
still have not locked your dependencies, expect your Chef runs to break.

I would love more help from people deploying apps on Thin, Unicorn, Gunicorn,
and Celery in working out what options are common enough to be included in the
DSL.

## Questions?

If anyone has any questions on any of these cookbooks or my future plans for
them please don't hesitate to get in contact with me. You can reach me at
<a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;">&#110;&#x6f;&#97;&#x68;&#x40;&#x63;&#111;&#100;&#101;&#x72;&#x61;&#x6e;&#x67;&#x65;&#114;&#46;&#110;&#x65;&#x74;</a>
or any of the methods on my [contact page](/contact/).
