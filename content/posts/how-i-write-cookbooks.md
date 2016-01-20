---
title: How I Write Cookbooks
date: 2016-01-19
published: false
---

# Disclaimer

This workflow works for me. I do not warrant its fitness for anyone else at this
point, at least not as a whole. My use case of working almost exclusively on
highly reusable community cookbooks is not something most people share, nor
should they. Caveat emptor.

# The Broad Strokes (*tl;dr*)

I write my projects as Ruby gems, using [Halite](https://github.com/poise/halite)
to convert to cookbooks for testing and on release. My gem code is mostly divided
into resources (and their providers), mixins, and inversion providers. I test
locally using ChefSpec with a lot of custom helpers to allow for things like
testing in-line blocks of recipe code, and with Test Kitchen on top of Docker
and Serverspec. My tests run remotely using Travis CI and a Docker server donated
by Rackspace. I release cookbooks to RubyGems using Bundler's `rake release`
and to Supermarket using [Stove](https://github.com/sethvargo/stove).

# Writing the Code

My editing environment is relatively simple. Sublime Text with maybe a half-dozen
snippets for Ruby aphorisms but overall just a stock text editor. Right now I
start off most new cookbooks by copying the skeleton from an existing one. This
is slow and error-prone, and I'm working on a code generator in Yeoman to help
streamline this, but in general the skeleton looks like this:

```
poise-thing/
  chef/
    attributes/
      default.rb
  lib/
    poise_thing/
      resources/
        thing.rb
      cheftie.rb
      resources.rb
      version.rb
    poise_thing.rb
  test/
    cookbooks/
      poise-thing_test/
        recipes/
          default.rb
        metadata.rb
    docker/
    gemfiles/
      chef-12.gemfile
      master.gemfile
    integration/
      default/
        serverspec/
          default_spec.rb
    spec/
      resources/
        thing_spec.rb
      spec_helper.rb
  .gitignore
  .kitchen.yml
  .travis.yml
  .yardopts
  Berksfile
  CHANGELOG.md
  Gemfile
  LICENSE
  poise-thing.gemspec
  Rakefile
  README.md
```

Starting from the top, everything goes in a folder. For branding and namespacing
on Supermarket I put all my cookbooks under `poise-` prefix. I would highly
recommend others to stake out a similar prefix as the discussion around namespaces
in Chef has reached a likely-permanent standstill.

Inside that I have three top-level directories: `chef/`, `lib/`, and `test/`. As
one might expect, `chef/` holds Chef-specific files that Halite can't generate
automatically from the gem code, mostly attributes and recipe files. The `lib/`
folder holds the gem's source code, and the `test/` folder holds unit and
integration tests. After that we have a smattering of root-level configuration
files. Let's dive into each section.

## `chef/` Files

Any files under here are recursively copied in to the final cookbooks. For me
this means, at most, one attributes file and one recipe. I try to keep both to
a minimum, but some things do still call for being exposed that way.

## `lib/` Files

`lib/` forms the base of the gem's code. Everything that will be `require`'d
goes in here. For aesthetic reasons I can no longer really remember, I tend to
name my projects with a `poise-` prefix but I prefer `poise_` in the `require`
path.

The first file in any gem is `lib/poise_thing.rb`. This defines the root
namespace of the gem's code. As a policy, I try to make sure that this file
can be `require`'d safely even outside of a Chef context. Generally this means
it will just be a single Ruby module with some `autoload` calls to pull in
second-level files as needed.

```ruby
module PoiseThing
  autoload :Resources, 'poise_thing/resources'
  autoload :VERSION, 'poise_thing/version'
end
```

The simplest second-level file is `verison.rb`, which just contains the gem
version. During development this is set to something like `'1.0.0.pre'`. This
file is managed automatically by my `release:bump` Rake tasks which we'll get to
later.

```ruby
module PoiseThing
  VERSION = '1.0.0.pre'
end
```

After that we have `cheftie.rb`. Current this is part of how Halite loads
code from inside the Chef run, but the plan is to replace it with a more
Bundler-style mechanism after [Chef RFC060](https://github.com/chef/chef-rfc/blob/master/rfc060-metadata-gem-installation.md)
is implemented. As it stands, `cheftie.rb` acts as an "entry point" which is
`require`'d by Chef during cookbook loading, so from here I can decide what
code should loaded eagerly and what can be lazy loaded as needed. For a simple
cookbook all I need is to eagerly load all the custom resources.

```ruby
require 'poise_thing/resources'
```

The `resources.rb` loads everything under the `resources/` folder. Remember that
YARD requires two blank lines between the license header and the first `module`
line, which I traditionally put after the block of `require`s.

```ruby
require 'poise_thing/resources/thing'


module PoiseMonit
  # Chef resources and providers for poise-thing.
  #
  # @since 1.0.0
  module Resources
  end
end
```

Inside `resources/` we have the normal resources and providers for the cookbook.
In some of my cookbooks you'll see some providers elsewhere (`service_providers/`,
`python_providers/`, etc), but those are for cases where a single resource has
a large number of providers. For most resources, there is a one-to-one
correspondence between the resource and provider, so they live together.

Even a relatively small resource is fairly complex so let's look at it in pieces.
The start of the file is the `require`s to pull in the needed libraries, and
then declaring the module namespace for the resource and provider classes. I use
YARD's `(see ...)` helper to avoid duplicating documentation between the
container module and the resource class.

```ruby
require 'chef/resource'
require 'chef/provider'
require 'poise'


module PoiseThing
  module Resources
    # (see Thing::Resource)
    # @since 1.0.0
    module Thing
      # Resource class
      # Provider class
    end
  end
end
```

The resource class subclasses `Chef::Resource` to get all the core behaviors,
and then pulls in my Poise helpers, gives itself a name, and declares which
actions it supports. The first action automatically becomes the default unless
overridden. After that we define a bunch of resource properties. For a variety
of not-very-good reasons I still declare them using `attribute()` instead of
`property()`, but that is something I should fix. As before, everything is
documented using YARD.

```ruby
# A `thing` resource to manage a thing.
#
# @provides thing
# @action create
# @action remove
# @example
#   thing '/opt/thing' do
#     name 'My Thing'
#   end
class Resource < Chef::Resource
  include Poise
  provides(:thing)
  actions(:create, :remove)

  # @!attribute path
  #   Path to the thing. Defaults to the name of the resource.
  #   @return [String]
  attribute(:path, kind_of: String, name_attribute: true)
  # @!attribute name
  #   Name of the thing.
  #   @return [String]
  attribute(:name, kind_of: String, required: true)
end
```

The provider is overall pretty similar to the resource in structure at the top.
Each action is defined as a method, which uses `notifying_block` internally,
which calls a bunch of methods to implement the behavior as resources. Breaking
things in to so many methods introduces some mental overhead, but allows for a
lot more flexibility when extending the provider in a subclass.

```ruby
# Provider for `thing`.
#
# @see Resource
# @provides thing
class Provider < Chef::Provider
  include Poise
  provides(:thing)

  # `create` action for `thing`. Create the thing.
  #
  # @return [void]
  def action_create
    notifying_block do
      create_thing
    end
  end

  # `remove` action for `thing`. Remove the thing.
  #
  # @return [void]
  def action_remove
    notifying_block do
      remove_thing
    end
  end

  private

  # Create a thing.
  def create_thing
    file new_resource.path do
      content new_resource.name
    end
  end

  # Remove a thing.
  def remove_thing
    file new_resource.path do
      action :delete
    end
  end
end
```

As I add new resources, I repeat this same rough pattern. Each gets added to
the `resources.rb` file so they get loaded by default inside Chef. If the gem
is going to declare any mixins, I'll usually put them at the `lib/poise_thing/`
level but my standard template doesn't include any.

## `test/` Files

The `test/` directory holds my fixture cookbook, Docker authentication keys,
Gemfiles for Travis, and both unit and integration tests. Some people prefer
putting unit tests under a top-leve `spec/` folder but that makes me cranky.

The fixture cookbook is used by the integration tests to run anything that isn't
exposed via a default recipe on the cookbook (which is usually most of it).
Again, for reasons forgotten even to me, I put this under `test/cookbooks/poise-thing_test`.
Given that I really really rarely have more than one, I should probably
collapse that down but for now this is what we have. Inside that is a cookbook
with a minimal `metdata.rb`.

```ruby
name 'poise-thing_test'
depends 'poise-thing'
```

The `recipes/default.rb` contains whatever recipe code I want to test the
behavior of, usually a bunch of different invocations of the cookbook's
resources.

```ruby
thing '/opt/thing1' do
  name 'Thing One'
end

thing '/opt/thing2' do
  name 'Thing Two'
end
```

Moving along down the folder list we have `test/docker/`. In this folder you'll
find `docker.ca` and `docker.pem`. The first is a the public CA certificate for
my Docker server, and the second is both the certificate and encrypted private
key for Docker TLS authentication. These are used by Travis CI to run my
integration tests. I currently generate these with a gross knife plugin, but
the [Docker documentation](https://docs.docker.com/engine/articles/https/)
covers the basics. I'll expand on my CI setup later on.

Next up we have `test/gemfiles/`. This contains Gemfiles for the Travis CI build
matrix. For most cookbooks I have two builds, one on the latest Chef release and
one on Chef's git master branch (or the latest nightly for integration tests).
The `chef-12.gemfile` pulls in the project-level Gemfile and pins the Chef
version.

```ruby
eval_gemfile File.expand_path('../../../Gemfile', __FILE__)

gem 'chef', '~> 12.0'
```

The `master.gemfile` is a bit more complex, pulling in Chef as well many other
dependencies from git.

```ruby
eval_gemfile File.expand_path('../../../Gemfile', __FILE__)

gem 'chef', github: 'chef/chef'
gem 'halite', github: 'poise/halite'
gem 'poise', github: 'poise/poise'
gem 'poise-boiler', github: 'poise/poise-boiler'
```

Having the master builds combined with [nightly builds](https://nightli.es/)
helps catch breaking changes in upstream code before release.

After that we have `test/integration/`, the normal home for Test Kitchen
integration tests. We'll get to my `.kitchen.yml` configuration in a moment, but
for these purposes I only ever have one suite named `default` and one spec so
the only file in there for most cases is `test/integration/default/serverspec/default_spec.rb`.
InSpec is a newer replacement for Serverspec, but due to some changes in the
runtime structure I've not yet been able to move my integration tests over. It
is something I'm looking in to for the future though, as InSpec and Train add
additional resource types. The specs themselves are generally fairly simple.

```ruby
require 'serverspec'
set :backend, :exec

describe file('/opt/thing1') do
  its(:content) { is_expected.to eq 'Thing One' }
end

describe file('/opt/thing2') do
  its(:content) { is_expected.to eq 'Thing Two' }
end
```

As always, take care to test your code, not Chef itself. In this reduced example
it is hard to demonstrate this, but take a look over the integration suites in
some of my other cookbooks.

Finally we come to unit tests, which are usually the bulk of my work by both
SLOC and time. My unit tests live under `test/spec/`, but are otherwise fairly
normal specs. The first piece in any spec tests is the `spec_helper.rb`. Here
we see the first mention of `poise-boiler`, my boiler-plate reduction library.
I standardized all my cookbooks so they can use the same code in some places
without having to repeat it all, so most of the complex logic for setting up
the spec helpers lives off in that other gem.

```ruby
require 'poise_boiler/spec_helper'
require 'poise_thing'
require 'poise_thing/cheftie'
```

Then we have the specs for the `thing` resource in `test/spec/resources/thing_spec.rb`.
Other than ending in `_spec.rb` there is not specific name requirements, but I
try to roughly match the structure of the gem code. This makes heavy use of the
Halite spec helpers for things like defining `step_into()` at the example group
level and recipes defined in blocks.

```ruby
require 'spec_helper'

describe PoiseThing::Resources::Thing do
  step_into(:thing)

  context 'action :create' do
    recipe do
      thing '/opt/thing' do
        name 'My Name'
      end
    end

    it { is_expected.to render_file('/opt/thing').with_content('My Name') }
  end # /context action :create

  context 'action :delete' do
    recipe do
      thing '/opt/thing' do
        action :delete
      end
    end

    it { is_expected.to delete_file('/opt/thing') }
  end # /context action :delete
end
```

