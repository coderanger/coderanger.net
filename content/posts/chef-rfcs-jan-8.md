---
title: Accepted Chef RFCs for Jan 8
date: 2015-01-08
hire_me: Looking for an engineer? I'm <a href="/hire-me/">looking for a new opportunity</a>!
---

# Accepted RFCs

This week one RFC has been provisionally accepted.

## [Dialects in Chef](https://github.com/opscode/chef-rfc/pull/71)

*[IRC logs](https://botbot.me/freenode/chef-hacking/msg/29059931/)*

The proposes adding hooks to Chef to allow supporting other languages and file
formats for Chef data. The plan is to accept the RFC on the condition that no
new formats are added within Chef core.

# RFCs Being Discussed

Three RFCs have been discussed in the past two weeks.

## [Attribute API 2](https://github.com/opscode/chef-rfc/pull/77)

*[IRC logs](https://botbot.me/freenode/chef-hacking/msg/29061434/)*

This proposal outlines ideas and rationale for a revamped and improved API
for node attributes and related data. The goal is to radically simplify the
node attributes system, and clean up a lot of the internals. There is still a
lot of debate about how to build the new syntax for getting and setting
attributes, but some broad designs have taken shape.

## [Ruby data bag items](https://github.com/opscode/chef-rfc/pull/79)

This suggests adding a Ruby DSL format for data bag items. This is mostly on
ice pending further discussion and implementation of the dialects RFC. The
dialects system will provide hooks that could be used to implement this RFC,
either inside Chef or as a knife plugin.

## [Robust Attribute Tracing Support](https://github.com/opscode/chef-rfc/pull/75)

*[IRC logs](https://botbot.me/freenode/chef-hacking/msg/29061071/)*

This proposes adding a tracing system to allow for easier debugging of node
attribute issues. This is going to likely be folded in the Attributes 2.0 work
as a requirement on the new API and internal design.

# Next Meeting

The next community meeting is scheduled for
[Thursday, January 22nd at 9AM PST](http://timesched.pocoo.org/?date=2015-01-22&tz=pacific-standard-time!,eastern-standard-time,gb:london,au:sydney,de:berlin&range=540,600).
As always, the meeting will be held in the
[`#chef-hacking` channel](http://webchat.freenode.net/?randomnick=1&channels=%23chef-hacking)
on Freenode IRC. Hope to see you there!
