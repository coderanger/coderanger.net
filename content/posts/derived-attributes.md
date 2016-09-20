---
title: Derived Attributes in Chef
date: 2014-08-25
hire_me: Like this Chef tip? Hiring Chef engineers or tool developers? I'm looking for a new team! Check out my <a href="/looking-for-group/">Looking for Group</a> post for details.
---

# **Update**

I've written a helper cookbook to make this much easier. Check it out [on GitHub](https://github.com/poise/poise-derived).

As the Chef community has moved more and more towards wrapper cookbooks,
derived attributes have become a persistent thorn in the side of recipe
authors.

# What is a Derived Attribute?

A node attribute which depends on the value of another node attribute. As
roles, nodes, and environments must be entirely static, this can currently only
happen in cookbooks. A common example is including a version number in a path
or URL:

```ruby
default['version'] = '1.0'
default['url'] = "http://example.com/#{node['version']}.zip"
```

# Why is this a Problem?

Chef builds the attributes for the current node in several stages. First
the roles, environment, and node data is deep merged together. Then the
attribute files for all cookbooks in the current dependency set are loaded in
the order specified by dependencies ([topological sort](https://en.wikipedia.org/wiki/Topological_sorting)).

What this means is if we make a wrapper cookbook with an updated version
attribute, it won't have the desired effect:

```ruby
default['version'] = '2.0'
```

Remembering that attribute files are processed in dependency order, that means
that the evaluated code is effectively:

```ruby
default['version'] = '1.0'
default['url'] = "http://example.com/#{node['version']}.zip"
default['version'] = '2.0'
```

By the time our wrapper cookbook tries to set a new version, the URL has
already been computed. The expedient fix for this is to simply override
both `version` and `url` in our wrapper cookbook, but this means duplicating
a lot of attributes and tends to be fragile.

This can work as expected as long as the override is specified in a role or
environment, as those are fully prepared before any cookbook attributes are
evaluated. Unfortunately this can mean mixing wrapper cookbooks and roles,
possibly leading to confusion and mess.

# Delayed Interpolation

My proposed solution to this for cookbooks wanting to be reusable or wrappable
is to use lazy evaluation for the derived components. Our earlier attributes
would become:

```ruby
default['version'] = '1.0'
default['url'] = "http://example.com/%{version}.zip"
```

The `%{}` and `%` operators in Ruby allows delaying the string interpolation
until later. The `%{}` defines named placeholders in the string and `%` binds
a given input into the placeholders.

In our recipe code we would then have something like:

```ruby
remote_file '/tmp/example.zip' do
  source node['url'] % {version: node['version']}
end
```

By delaying this interpolation until recipe compile time, we leave room for
all the wrapper cookbook attributes to have been evaluated.

# tl;dr

Don't use `"#{}"` in cookbook attributes, use `"%{}"` instead.

*UPDATE:* I've written a helper cookbook to make this much easier. Check it out [on GitHub](https://github.com/poise/poise-derived).
