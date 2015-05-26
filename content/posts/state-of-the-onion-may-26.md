---
title: State of the Onion for May 26
date: 2015-06-26
---

It has now been almost six months since I started on my adventures in application
deployment and I want to update everybody on how things are progressing. First
off a huge "thank you" to my [Kickstarter backers](https://github.com/poise/application/blob/master/SUPPORTERS.md)
and [Bloomberg](http://www.bloomberg.com/company/technology/) for supporting
this development time. It truly would not have been possible without community
support.

## Halite

The biggest new development so far has been [Halite](https://github.com/poise/halite).
While not specifically related to application deployment, it has greatly
improved my development workflow for cookbooks. You can read more in the Halite
documentation, the short version is that Halite allows converting normal
Ruby gems in to Chef cookbooks. This is handy for cookbooks that are otherwise
99% library code anyway as I can use the normal gem workflow tools more
effectively, and then convert to a cookbook for release/upload. Halite 1.0 is
available on Rubygems.org and should be ready for general use if you find the
workflow helpful. I wouldn't go so far as to call it a "best practice" and
normal cookbooks are still perfectly fine if you prefer them. All my Halite'd
cookbooks are released in cookbook form to the Supermarket, so you can use them
without needing to care about any of this.

If you want to try out prerelease versions of my cookbooks you will have to
do a little extra work to get Berkshelf to recognize them. Halite includes a
new source location for Berkshelf, `gem: 'name'`. To use a prerelease version of
a Halite-based cookbook/gem you first need to install the gem itself, generally
through a Gemfile:

```ruby
gem 'poise-application', github: 'poise/application'
```

Once the gem is installed you can use it in your Berksfile:

```ruby
source 'https://supermarket.chef.io/'
extension 'halite'
cookbook 'application', gem: 'poise-application'
```

Anything that integrates with Berkshelf (Test Kitchen, Chefspec, etc) will now
build the prerelease cookbook from the gem code as needed.

## Poise

[Poise](https://github.com/poise/poise) has seen big internal improvements and
restructuring around Halite and some other workflow tools I've written, but as a
user it is still pretty much the same. A few new helpers have been added
including Fused mode where action implementations can be written directly in the
resource class, and Inversion which adds dependency injection/inversion to the
Chef resource and provider model.

Poise 2.0 has been released to both Rubygems.org and the Supermarket.

## Application Cookbooks

The core `application` cookbook has been rebuilt from scratch to be more
flexible and powerful. It no longer uses the `deploy` resource internally and
many of the old bugs are gone thanks to switching to Poise instead of the early,
ad-hoc versions of the helpers I wrote all those years ago. It will still be
plugin-based, but rather than a model based around the `deploy` resource
callbacks plugins are now nested sub-resources and can define their own internal
structure as needed. This also means that the explicit deployment phases are
gone, instead relying on the ordering of resources in your code.

Two of the plugin cookbooks are relatively complete. `application_git` provides
support for deploying application code from a git repository, including all the
deploy key handling the old `application` resource handled internally.
`application_ruby` has been converted over to the new structure with resources
for `bundle_install`, `rackup`, `thin`, `unicorn`, and `rails`. Passenger
support in the old cookbook was minimal at best and is going to be put off to
its own `application_passenger` cookbook to be written in the future.

An example of a full Rails deployment and configuration using the new cookbooks:

```ruby
include_recipe 'build-essential'

package %w{ruby-dev zlib1g-dev libsqlite3-dev}

application '/opt/test_rails' do
  git 'https://github.com/poise/test_rails.git'
  bundle_install do
    deployment true
    without %w{development test}
  end
  rails do
    database 'sqlite3:///db.sqlite3'
    secret_token 'd78fe08df56c9'
  end
  unicorn do
    port 8080
  end
end
```

Next on the list is to rebuild the `application_python` cookbook, and then
`application_javascript` and `application_java` after that.

## Poise Service Cookbook

As part of the application deployment work I found a need to have a generic
service configuration API for Chef. In the above example, I need to install
unicorn as a service, but from the `application_ruby` cookbook I have no way to
know which service framework the end-user wants to do that with. Traditionally
we've worked around this by ignoring the end-user and hard-wiring things to use
whatever system is generally dominant in that community, Runit for Ruby and
Supervisord for Python.

[`poise-service`](https://github.com/poise/poise-service) uses the new Inversion
helper in Poise to allow the library cookbook code to stay generic while the
end-user can configure which underlying service framework to use and how to
set it up. It currently has support for SysVInit, Upstart, Systemd, and Runit.
Support for Supervisord will be added when I get to that point in the
`application_python` rebuild.

An example of using `poise-service` to create an init script for Apache:

```ruby
poise_service_user 'www-data'

poise_service 'apache2' do
  command '/usr/sbin/apache2 -f /etc/apache2/apache2.conf -DFOREGROUND'
  stop_signal 'WINCH'
  reload_signal 'USR1'
end
```

You can find more information about `poise-service` in
[the documentation](https://github.com/poise/poise-service#resources).
`poise-service` and `poise-service-runit` 1.0 have been released to both
Rubygems.org and the Supermarket.

## Poise Ruby Cookbook

[`poise-ruby`](https://github.com/poise/poise-ruby) uses the same dependency
inversion approach as `poise-service` but for installing Ruby runtimes. It
currently supports installing from system packages and from `ruby-build` (the
underlying build tool used by both rbenv and chruby, and rvm soon). This is
still prerelease but should be ready for external testing and will hopefully
be released shortly. If you have ever struggled with RVM or Rbenv in Chef
recipes I would greatly value your feedback on the design and functionality.

## Incoming Cookbooks

As part of the Python and Javascript revamps I plan to work on equivalents to
`poise-ruby` for each of those. Java would be nice too, but is enough of a mess
that I don't currently plan to rework the `java` cookbook itself. Bloomberg is
also going to support application deployment plugins for Go and Erlang, as well
as exploratory work on integrating service discovery frameworks like ZooKeeper
and Consul in to Chef for situations where Chef Search is not available or
usable.

## Secrets Management

Totally unrelated to the above but I wanted to mention that there have been
several interesting new entries in to the field of
[secrets management](/chef-secrets/) and while all are still very new they are
worth following in the hopes they will be proven safe enough for production use.
These include [Sneaker](https://github.com/codahale/sneaker),
[KeyWhiz](https://square.github.io/keywhiz/), and [Vault](https://vaultproject.io/).
As part of improving application deployment I would like to see deep integration
between these systems and Chef, but I don't currently have time scheduled to
work on this.

## Questions?

If anyone has any questions on any of these cookbooks or my future plans for
them please don't hesitate to get in contact with me. You can reach me at
<a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;">&#110;&#x6f;&#97;&#x68;&#x40;&#x63;&#111;&#100;&#101;&#x72;&#x61;&#x6e;&#x67;&#x65;&#114;&#46;&#110;&#x65;&#x74;</a>
or any of the methods on my [contact page](/contact/).
