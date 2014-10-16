---
title: Accepted Chef RFCs for Oct 15
date: 2014-10-15
hire_me: Looking for help getting the most out of Chef? Check out my <a href="/training/">training</a> and <a href="/consulting/">consulting</a> services.
---

This week five RFCs have been accepted, planned for inclusion in Chef 12:

## [RFC 22: Arbitrary Cookbook Identifiers](https://github.com/opscode/chef-rfc/blob/master/rfc022-arbitrary-cookbook-identifiers.md)

This defines a new API to manage cookbooks with identifiers other the current
three-integer-semver structure in use now.

## [RFC 23: Chef 12 Attributes Changes](https://github.com/opscode/chef-rfc/blob/master/rfc023-chef-12-attributes-changes.md)

This defines several new methods on Node to manipulate attributes. This will
restore some functionality that was lost during the Chef 11 attributes rewrite,
including safely deleting attributes and assigning over an existing hash.

## [RFC 24: Local Mode Default](https://github.com/opscode/chef-rfc/blob/master/rfc024-local-mode-default.md)

This outlines plans to change chef-client and knife to use local-mode by default
if no server URL is specified.

## [RFC 25: Multitenant Chef Client Support](https://github.com/opscode/chef-rfc/blob/master/rfc025-multitenant-chef-client-support.md)

This adds additional configuration options to better support multi tenant Chef
Servers, such as Chef Server 12.

## [RFC 26: Remove HTTP Config Files](https://github.com/opscode/chef-rfc/blob/master/rfc026-remove-http-config-files.md)

This deprecates a relatively unknown feature whereby chef-client can download
its configuration directly from an HTTP server. Given how little this feature is
believed to be used, an aggressive deprecation schedule will be used such that
the feature will throw a warning in future Chef 11 versions and be entirely
removed in Chef 12.
