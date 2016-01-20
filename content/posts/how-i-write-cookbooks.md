---
title: How I Write Cookbooks
date: 2016-01-20
---

<style type="text/css">
pre { background-color: #EEE; padding-left: 5px; }
</style>

# Disclaimer

This workflow works for me. I do not warrant its fitness for anyone else at this
point, at least not as a whole. My use case of working almost exclusively on
highly reusable community cookbooks is not something most people share, nor
should they. By the nature of this workflow, I talk about some
intermediate-to-advanced Ruby concepts, though you can probably just keep going
if you run into things you don't know.

Caveat emptor.

# The Broad Strokes (*tl;dr*)

I write my projects as Ruby gems, using [Halite](https://github.com/poise/halite)
to convert to cookbooks for testing and release. My gem code is mostly divided
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
  CODE_OF_CONDUCT.md
  Gemfile
  LICENSE
  poise-thing.gemspec
  Rakefile
  README.md
```

Starting from the top, everything goes in a folder. For branding and namespacing
on Supermarket I put all my cookbooks under `poise-` prefix. As an aside, I
would highly recommend others to stake out a similar prefix as the discussion
around namespaces in Chef has reached a likely-permanent standstill.

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

The simplest second-level file is `version.rb`, which just contains the gem
version. During development this is set to something like `'1.0.0.pre'`. This
file is managed automatically by my `release:bump` Rake tasks which we'll get to
later.

```ruby
module PoiseThing
  VERSION = '1.0.0.pre'
end
```

After that we have `cheftie.rb`. Currently this is part of how Halite loads
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
[YARD](http://yardoc.org/) requires two blank lines between the license header
and the first `module` line, which I traditionally put after the `require`s.

```ruby
require 'poise_thing/resources/thing'


module PoiseThing
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
with a minimal `metadata.rb`.

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
integration tests. I currently generate these with a [gross knife plugin I wrote](https://gist.github.com/coderanger/d5d762e99bba9c691099), but
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

  context 'action :remove' do
    recipe do
      thing '/opt/thing' do
        action :remove
      end
    end

    it { is_expected.to delete_file('/opt/thing') }
  end # /context action :remove
end
```

## Root Files

In the root of the gem's repository we have some general configuration and
documentation files. The first is a basic `.gitignore`. Notably I ignore the
lockfiles for Berkshelf and Bundler, [because reusable cookbooks are libraries](http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/).
Everything under `test/docker/` is ignored for safely, but this does mean the
two keys in there that should be under Git have to be added with `git add -f`.
This helps make sure I don't accidentally commit the unencrypted private key.

```
Berksfile.lock
Gemfile.lock
test/gemfiles/*.lock
.kitchen/
.kitchen.local.yml
test/docker/
coverage/
pkg/
.yardoc/
doc/
```

Then I have my `.kitchen.yml` config. Like with the spec helper, it mostly lives
in `poise-boiler`. The only data still managed directly in the file is the
suite configuration and even that is probably not long for this world. The
driver, provisioner, transport, and platform configurations are all handled
automatically by the helper.

```yaml
---
#<%% require 'poise_boiler' %>
<%%= PoiseBoiler.kitchen(platforms: 'linux') %>

suites:
- name: default
  run_list:
  - recipe[poise-thing_test]
```

I'll cover the overall structure of my CI setup later on, but the Travis
configuration for all cookbooks looks almost identical. The only thing that
changes is the `secure` key (which is trimmed for brevity), which contains the
passphrase to decrypt the Docker private key. The bulk of the logic for testing
lives inside the `rake travis` task, which comes from `poise-boiler`.

```yaml
---
sudo: false
cache: bundler
language: ruby
rvm:
- '2.2'
addons:
  apt:
    packages:
    - libgecode-dev
env:
  global:
  - USE_SYSTEM_GECODE=true
  - secure: l7GLeLWfqrrkxpc1R9gLasQ...7tyJ8nBix9WKnFZbowmHB3Q=
bundler_args: "--binstubs=$PWD/bin --jobs 3 --retry 3"
script:
- "./bin/rake travis"
gemfile:
- test/gemfiles/chef-12.gemfile
- test/gemfiles/master.gemfile
```

And as a final dotfile, my `.yardopts` for [YARD](http://yardoc.org/)
documentation builds. I've not really kept up with the documentation side of
things, but this is at least passable for most purposes.

```
--plugin classmethods
--embed-mixin ClassMethods
--hide-api private
--markup markdown
--hide-void-return
--tag provides:Provides
--tag action:Actions
```

Next we have some other documentation files. `README.md`, `CHANGELOG.md`,
`LICENSE`, and `CODE_OF_CONDUCT.md`. The first two are what you would expect.
The license is Apache 2.0, and the code of conduct is [Contributor Covenant](http://contributor-covenant.org/).
For the README in particular, I have a fairly standardized format. The badge
section at the top can be generated via `rake badges`.

```
# Poise-Thing Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-thing.svg)](https://travis-ci.org/poise/poise-thing)
[![Gem Version](https://img.shields.io/gem/v/poise-thing.svg)](https://rubygems.org/gems/poise-thing)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-thing.svg)](https://supermarket.chef.io/cookbooks/poise-thing)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-thing.svg)](https://codecov.io/github/poise/poise-thing)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-thing.svg)](https://gemnasium.com/poise/poise-thing)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to manage [a thing](https://example.com/).

## Quick Start

To create a thing:

​​``ruby
thing '/opt/thing' do
  name 'Thing Name'
end
``

## Resources

### `thing`

The `thing` resource manages a thing.

``ruby
thing '/opt/thing' do
  name 'Thing Name'
end
``

#### Actions

* `:create` – Create the thing. *(default)*
* `:remove` – Remove the thing.

#### Properties

* `path` – Path to the thing. *(name property)*
* `name` – Name of the thing. *(required)*

## License

Copyright 2016, Your Name

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```


There are a few more sections that I add as needed, but that's the overall
structure. As a warning for those trying to copy-pasta, I trimmed the code fence
markers in that block to make them not terminate the outer block.

After documentation we get to the `*files`. The `Berksfile` is used to integrate
the Halite conversion process in to Test Kitchen. In the future this might be
replaced with a dedicated provisioning hook, but for now it gets the job done.
The Berksfile sets the normal default source, enables the Halite extension,
configures gem conversion for the cookbook and every cookbook it depends on so
they are rebuilt on every test run in case a local dependency is changed, and
then a test group with the fixture cookbook and the apt cookbook, which is used
by default on Ubuntu platforms.

```ruby
source 'https://supermarket.chef.io/'
extension 'halite'

# Force the rebuild every time for development.
cookbook 'poise', gem: 'poise'
cookbook 'poise-thing', gem: 'poise-thing'

group :test do
  cookbook 'poise-thing_test', path: 'test/cookbooks/poise-thing_test'
  cookbook 'apt'
end
```

The `Rakefile` pulls in tasks from `poise-boiler`.

```ruby
require 'poise_boiler/rakefile'
```

And then the `Gemfile` handles dispatching to local development copies of the
dependent gems. The `dev_gem` helper method checks for a local version of the
code, then optionally a version from GitHub.

```ruby
source 'https://rubygems.org/'

gemspec path: File.expand_path('..', __FILE__)

def dev_gem(name, path: File.join('..', name), github: nil)
  path = File.expand_path(File.join('..', path), __FILE__)
  if File.exist?(path)
    gem name, path: path
  elsif github
    gem name, github: github
  end
end

dev_gem 'halite'
dev_gem 'poise'
dev_gem 'poise-boiler'
```

And finally we have the gemspec, `poise-thing.gemspec`. This fills in all the
normal gemspec metadata fields which Halite uses to generate the cookbook
metadata. It has runtime dependencies on `poise` and `halite`, and a development
dependency on `poise-boiler`. Any runtime dependency other than `halite` gets
converted into a cookbook dependency.

```ruby
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'poise_thing/version'

Gem::Specification.new do |spec|
  spec.name = 'poise-thing'
  spec.version = PoiseThing::VERSION
  spec.authors = ['Noah Kantrowitz']
  spec.email = %w{noah@coderanger.net}
  spec.description = 'A Chef cookbook for managing a thing.'
  spec.summary = spec.description
  spec.homepage = 'https://github.com/poise/poise-thing'
  spec.license = 'Apache 2.0'

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w{lib}

  spec.add_dependency 'halite', '~> 1.1'
  spec.add_dependency 'poise', '~> 2.5'

  spec.add_development_dependency 'poise-boiler', '~> 1.0'
end
```

# Testing the Code

In the last section we talked a bit about the testing set up in the various
files, now let's look at how to use it.

`poise-boiler` includes a Rake task to run the unit tests: `rake spec`. This
works like the `spec` task in most Ruby projects. You can also run
`rake debug spec` to run the tests with debugging output. By default the test
order is randomized. You can lock the order with an environment variable:
`SEED=123 rake spec`.

Integration tests are generally run locally via normal `kitchen` commands.
`rake chef:foodcritic` runs Foodcritic on the converted cookbook and
`rake chef:kitchen` will run `kitchen test -d always`. To run all test-related
tasks, there is a `rake test`, but generally this is used via the Travis wrappers.

The Test Kitchen configuration is set up to try and cut the overhead of the
testing system and generally get the fastest tests possible. It uses
`kitchen-docker` if the Docker authentication keys are available. It uses
a custom Dockerfile template and some `provision_commands` to cache Chef, the
busser gems, and some other support files in the Docker image. This allows
launching a test container with only a few seconds of work. To speed up
transferring the cookbook files, I use [`kitchen-sync`](https://github.com/coderanger/kitchen-sync).

# Travis CI

I use Travis CI to run tests on each change and on pull requests. Unfortunately
pull requests can't run integration tests for security reasons (Travis doesn't
expose encrypted project variables to PR tests because the PR might print or
otherwise compromise them), but it's still better than nothing. I control the
version of Chef being used through Bundler, so I don't install via ChefDK at
this time. I will state for the record that using Berkshelf (even indirectly via
Test Kitchen) outside of ChefDK is unsupported and please please don't bother
their development team if and when it breaks in weird ways (notably when they
upgrade the default Travis image this is going break horribly).

The Travis configuration is set to use their container infrastructure, this
allows faster test startup times but means you can't run commands as root.
That is why I run Docker against a remote host instead of locally, though as a
positive side effect I can put a lot more horsepower behind Docker than a
Travis test VM. It uses the new addons system to install the `libgecode` packages,
which will be used later when [installing the `dep-selector` gem](https://github.com/chef/dep-selector-libgecode#using-a-system-gecode-instead).

Travis uses the Gemfile path as part of the cache key, so each build in the
matrix gets its own gem cache. The Bundler-installed Rake then kicks off the
`travis` task. This handles downloading the latest `docker` binary, decrypting
the private key, and running the test tasks as needed.

# Making a Release

Most of the release logic is wrapped up in three similar tasks: `rake release`,
`rake release:minor`, and `rake release:major`. All follow the same process,
first the `version.rb` file is bumped to the next patch/minor/major version,
then a tag is created, the new release is pushed to both RubyGems and Supermarket
(using Stove), and the version is bumped to the new patch prerelease.

This has a few more "oops" checks than the default Bundler release task, like
ensuring the changelog has been updated and using GPG signed tags if possible.

# Rake Tasks

A lot of the repetitive tasks of this workflow are bundled up inside Rake tasks.
You can always see all the tasks via `rake -T` but to cover the major ones:

* `badges` – Generate README badges for the project.
* `build` – Create a `.gem` package and convert the gem to a cookbook. Useful
  for debugging Halite conversion issues.
* `check` – Display a summary of the current project, all changed files and all
  commits since the last release.
* `checkall` – Display a summary of all my projects.
* `chef:foodcritic` – Run the Foodcritic linter on the cookbook.
* `release`, `release:minor`, `release:major` – Create a new patch/minor/major
  release.
* `release:bump`, `release:bump:minor`, `release:bump:major` – Run just the
  version bump for a patch/minor/major.
* `spec` – Run unit tests.
* `travis` – Run CI processing.

# External Services

I use a number of hosted services as part of my workflow. Most are free, though
Rackspace has been kind enough to donate the use of their cloud services to
cover the rest. In no particular order:

* [Travis CI](https://travis-ci.org/) runs all my builds. I couldn't function
  without it.
* [Nightlies](https://nightli.es/) runs nightly rebuilds automatically to catch
  upstream breakages.
* [CodeCov](https://codecov.io/) archives my code coverage reports and provides
  coverage diffs on pull requests.
* [CodeClimate](https://codeclimate.com/) runs static analysis, though I haven't
  tuned my configs with them so the data isn't as valuable as it could be.
* [Gemnasium](https://gemnasium.com/) analyzes gem dependencies and lets me know
  when things get updated or are out of date.
* [GitHub](https://github.com/) hosts my code and issue tickets.

I've got a dashboard for all of these data services at [dash.poise.io](https://dash.poise.io/),
but it needs some love to be more useful.

# In Summary

I have been using this flow and style for about a year now, with constant
improvements throughout. As I said before, I don't think this is the right
style for everybody, but hopefully you get some value out of a piece here or
there. If you have any questions about any of this, please don't hesitate to
ask me via <a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;">email</a>,
IRC, or [Twitter](https://twitter.com/kantrn).
