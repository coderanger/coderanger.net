---
title: Accepted Chef RFCs for Nov 25
date: 2014-11-25
hire_me: Looking for an engineer? I'm <a href="/hire-me/">looking for a new opportunity</a>!
---

# Accepted RFCs

This week three RFCs have been accepted and one has been updated.

## [RFC 32: Powershell DSC Resource Modules](https://github.com/opscode/chef-rfc/blob/master/rfc032-dsc-resource-modules.md)

The adds a resource to the Powershell cookbook for DSC resource
modules.

```ruby
powershell_dsc_module 'test_module' do
  remote_url 'https://example.com/test_module.zip'
end
```

## [RFC 33: Root Aliases in Cookbooks](https://github.com/opscode/chef-rfc/blob/master/rfc033-root-alises.md)

This adds two aliases to the root folder of a cookbook for the common case of
a single attributes file or a single recipe. This allows not having a folder
containing a single file for these cases. The two aliases will be
`/attributes.rb` and `/recipe.rb`.

## [RFC 34: Ruby 1.9.3 EOL](https://github.com/opscode/chef-rfc/blob/master/rfc034-ruby-193-eol.md)

Chef Client 12 will require Ruby 2.0 or newer. This is being forced now because
it is expected that Ruby 1.9.3 will be end-of-lifed during the the support
lifetime of the 12.x branch. All omnibus packages will include compatible
versions so this will only affect people installing Chef as a gem themselves.

## [Update to RFC 21: Update OS X Version Support](https://github.com/opscode/chef-rfc/pull/70/files)

OS X 10.10 is now an officially supported platform, and 10.6 and 10.7 have been
removed.

# RFCs Being Discussed

Three RFCs have been discussed since the last community meeting.

## [Token Authentication for Chef Server](https://github.com/opscode/chef-rfc/pull/65)

This proposal outlines adding a token-based authentication mechanism to Chef
Server. Discussion at the community meeting was generally positive, but we
wanted to wait until the chef-server team could weigh in on the feasibility
of the suggested design. Given the complexity of the problem, things will likely
evolve once implementation begins, and the RFC will be updated as needed.

## [Audit Mode](https://github.com/opscode/chef-rfc/pull/69)

The proposal outlines adding a testing DSL to Chef recipes based on RSpec and
Serverspec to allow for easier testing integration. Overall positive reaction
from the meeting, with some dissent about if we should continue the current
prototype as implemented entirely in Chef core. Discussion will continue on the
pull request.

## [Dialects in Chef](https://github.com/opscode/chef-rfc/pull/71)

The proposes adding hooks to Chef to allow supporting other languages and file
formats for Chef data.

# Next Meeting

The next community meeting is scheduled for
[Thursday, December 11th at 9AM PST](http://timesched.pocoo.org/?date=2014-12-11&tz=pacific-standard-time!,eastern-standard-time,gb:london,au:sydney,de:berlin&range=540,600).
As always, the meeting will be held in the
[`#chef-hacking` channel](http://webchat.freenode.net/?randomnick=1&channels=%23chef-hacking)
on Freenode IRC. Hope to see you there!
