---
title: Accepted Chef RFCs for Nov 13
date: 2014-11-13
hire_me: Looking for an engineer? I'm <a href="/hire-me/">looking for a new opportunity</a>!
---

# Accepted RFCs

This week five RFCs have been accepted.

## [RFC 27: File Content Verification](https://github.com/opscode/chef-rfc/blob/master/rfc027-file-content-verification.md)

This defines an extension to the resource DSL to allow file-type resources
(`file`, `cookbook_file`, `template`, `remote_file`) to verify content before
continuing. The common use case for this is checking server configuration
files are valid. This RFC had been provisionally accepted several weeks ago but
was only merged this week.

## [RFC 28: Mailing List Migration](https://github.com/opscode/chef-rfc/blob/master/rfc028-mailing-list-migration.md)

This RFC defines the plan to migrate the Chef mailing lists from locally-hosted
Sympa to Google Groups.

## [RFC 29: Governance Policy](https://github.com/opscode/chef-rfc/blob/master/rfc029-governance-policy.md)

This RFC defines the new governance policy for Chef as a project, establishing
an advisory board to provide input on the future of Chef. See
[my post](/chef-governance/) for more information and an overview of the policy.

## [RFC 30: Maintenance Policy](https://github.com/opscode/chef-rfc/blob/master/rfc030-maintenance-policy.md)

This RFC defines how Chef will be maintained going forward. This includes how
how people will get commit access and how we will determine the roadmap. See
[my post](/chef-governance/) for more information and an overview of the
policy.

## [RFC 31: Replace Solo With Local Mode](https://github.com/opscode/chef-rfc/blob/master/rfc31-replace-solo-with-local-mode.md)

This lays out an overall plan for rebuilding chef-solo on top of chef-client's
`--local` mode. This will be done incrementally, and 100% compatibility with
solo as it stands today is a requirement.

# RFCs Being Discussed

Four RFCs have been discussed since the last community meeting.

## [Adding PowerShell DSC Module Resource](https://github.com/opscode/chef-rfc/pull/57)

This proposes adding a Chef resource to configure PowerShell DSC modules.

## [Token Authentication for Chef Server](https://github.com/opscode/chef-rfc/pull/65)

This proposal outlines adding a token-based authentication mechanism to Chef
Server.

## [Root Aliases in Cookbooks](https://github.com/opscode/chef-rfc/pull/66)

This proposes aliases for commonly used files in cookbooks to simplify the
folder layout.

## [Audit Mode](https://github.com/opscode/chef-rfc/pull/69)

The proposal outlines adding a testing DSL to Chef recipes based on RSpec and
Serverspec to allow for easier testing integration.

# Next Meeting

Due to the Thanksgiving holiday in the US, the next developer meeting has
been rescheduled to [Tuesday, November 25th at 9AM PST](http://timesched.pocoo.org/?date=2014-11-25&tz=pacific-standard-time!,eastern-standard-time,gb:london,au:sydney,de:berlin&range=540,600).
As always, the meeting will be held in the `#chef-hacking` channel on Freenode
IRC. Hope to see you there!
