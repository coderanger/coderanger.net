---
title: Accepted Chef RFCs for Nov 13
date: 2014-11-13
hire_me: Looking for help getting the most out of Chef? Check out my <a href="/training/">training</a> and <a href="/consulting/">consulting</a> services.
published: false
---

This week N RFCs have been accepted.

## [RFC 27: File Content Verification](https://github.com/opscode/chef-rfc/blob/master/rfc027-file-content-verification.md)

This defines an extension to the resource DSL to allow file-type resources
(`file`, `cookbook_file`, `template`, `remote_file`) to verify content before
continuing. The common use case for this is checking server configuration
files are valid.
