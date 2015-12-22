---
title: Serverspec and Chef 11
date: 2015-12-21
---

[Serverspec](http://serverspec.org/) is a server testing library used often
with Test-Kitchen, through the [busser-serverspec](https://github.com/test-kitchen/busser-serverspec)
plugin. Serverspec uses an internal helper gem called `specinfra` that
implements much of the heavy lifting of the different types of checks that
Serverspec offers. While Test-Kitchen uses Serverspec in `exec` mode for local
execution, it also supports an SSH-based remote execution mode using Ruby's
`net-ssh` gem.

# Enough with the back story

Between versions 2.44.7 and 2.44.8, specinfra changed its dependencies to allow
the use of `net-ssh` version 3.0. This creates a problem with Chef 11 as it
still uses the end-of-life'd Ruby 1.9 and `net-ssh` 3.0 is incompatible with
Ruby 1.9.

# tl;dr

Create `test/integration/helpers/serverspec/Gemfile` with:

```ruby
source 'https://rubygems.org'
gem 'specinfra', '2.44.7'
gem 'serverspec', '2.24.3'
```

This will force the versions of both gems back to things compatible with Ruby 1.9
and thus Chef 11. You'll see a warning about the gems not being found the first
time you run `kitchen verify` on a new instance, but it will work fine after that.
Make sure you remember to remove this file when you upgrade to Chef 12.
