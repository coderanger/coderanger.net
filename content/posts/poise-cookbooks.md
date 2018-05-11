---
title: The Poise Family of Cookbooks
date: 2015-10-02
hire_me: Looking for an engineer? I'm <a href="/hire-me/">looking for a new opportunity</a>!
---

As part of the continuing development of my Kickstarter work, I've written a
lot of new cookbooks over the past few months. I would like to summarize a bit
about each of them so everyone knows what is out there. Some of these cookbooks
are still in the final stages of pre-release testing, so you may need to pull
them in from GitHub rather than the Supermarket for a little while longer.

# Service Management

## poise-service

The [`poise-service`](https://github.com/poise/poise-service) cookbook unifies
and streamlines creating and starting system services with Chef. Unlike the core
`service` resource which just handles enabling, disabling, starting, etc
existing service definitions, `poise-service` also creates the service
definition for you. This also allows some level of framework independence for
community cookbooks which would otherwise hard-code one specific service
management framework.

## poise-service-runit

The [`poise-service-runit`](https://github.com/poise/poise-service-runit)
cookbook adds support for Runit to `poise-service`. This uses the dependency
inversion helpers in Poise to allow [customizing a service resource in a wrapped
cookbook without forking](https://github.com/poise/poise-service#service-options).


# Language Management

## poise-ruby

The [`poise-ruby`](https://github.com/poise/poise-ruby) cookbook provides
resources for installing Ruby from system packages or RedHat's SCL packages.
It also has resources for installing Ruby gems, running `bundle install`, and
running Ruby scripts or programs with automatic handling for `bundle exec`.

## poise-ruby-build

The [`poise-ruby-build`](https://github.com/poise/poise-ruby-build) cookbook
adds support for using `ruby-build` to `poise-ruby`. This takes
the place of using tools like `rvm` or `rbenv` in a server environment.

## poise-python

The [`poise-python`](https://github.com/poise/poise-python) cookbook provides
resources for installing Python as `poise-ruby` does, with additional support
for the Portable PyPy binary builds to get started with PyPy quickly and easily.
As with Ruby, there are also resources for installing Python packages with `pip`,
managing virtualenvs, installing `requirements.txt` files, and running Python
scripts and commands. This replaces the now-deprecated [`python`](https://github.com/poise/python) cookbook.

## poise-javascript

The [`poise-javascript`](https://github.com/poise/poise-javascript) cookbook
follows the Ruby and Python cookbooks in offering support for install
server-side JavaScript environments like Node.js and io.js, as well as installing
packages using NPM.

## poise-languages

The [`poise-languages`](https://github.com/poise/poise-languages) cookbook has
shared helpers and utilities for the other language management cookbooks, and
will be pulled in automatically as a dependency when needed.


# Application Deployment

## application

The [`application`](https://github.com/poise/application) cookbook provides the
core `application` resource used with the other application deployment cookbooks.
This also contains core mixins used to create application deployment resources
more easily.

## application_git

The [`application_git`](https://github.com/poise/application_git) cookbook
extends the core `git` resource to support SSH deploy keys and a few other
deployment-oriented options.

## application_ruby

The [`application_ruby`](https://github.com/poise/application_ruby) cookbook
supports deploying Ruby web applications like Rails and Sinatra projects. It
supports running application services using Thin and Unicorn, as well as most
standard Rails deployment steps.

## application_python

The [`application_python`](https://github.com/poise/application_python) cookbook
adds support for Python web application frameworks like Django and Flask. It
also has support for deploying Celery and Gunicorn as services.

## application_javascript

The [`application_javascript`](https://github.com/poise/application_javascript)
cookbook provides resources for deploying server-side JavaScript applications
using NPM. It is a bit more generic than the other application language cookbooks
as there aren't specific deployment steps for different Node.js frameworks, but
it makes it easy to get a package installed and running as a service.

## application_examples

The [`application_examples`](https://github.com/poise/application_examples)
cookbook provides some complete real-world examples of deploying web
applications using these cookbooks, including a pastebin using Django and SQLite
and a todo list using Express and MongoDB.


# Secrets Management

## citadel

The [`citadel`](https://github.com/poise/citadel) cookbook provides DSL
helpers for an AWS-based secrets management workflow.


# Utility Cookbooks

These are cookbooks (and tools) that you may see in my code but are generally
for internal use or provide helpers for other cookbooks.

## poise

The [`poise`](https://github.com/poise/poise) cookbook, which kicked off much of
my redesign of Chef cookbooks, provides mixins and utilities to write resources
and providers more effectively without compromising reuse or extensibility.

## halite

The [`halite`](https://github.com/poise/halite) gem is a workflow tool used to
allow writing Chef code as normal Ruby gems and converting to cookbooks on the
fly. This allows leveraging more Ruby development tools like SimpleCov for code
coverage and Bundler for dependency management.

## poise-boiler

The [`poise-boiler`](https://github.com/poise/poise-boiler) gem keeps a lot of
boilerplate code for my specific Chef workflow in one place so it can be shared
more easily.


# tl;dr

I've got a suite of Chef cookbooks for managing Ruby, Python, and server-side
JavaScript across the full life cycle of configuration management needs. I think they are
awesome. If you have any questions about using any of these cookbooks, please
don't hesitate to contact me at <a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;" title="Email">&#110;&#x6f;&#97;&#x68;&#x40;&#x63;&#111;&#100;&#101;&#x72;&#x61;&#x6e;&#x67;&#x65;&#114;&#46;&#110;&#x65;&#x74;</a>.
