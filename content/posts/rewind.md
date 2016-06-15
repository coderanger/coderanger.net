---
title: RIP chef-rewind
date: 2016-06-15
hire_me: Thanks again to <a href="http://www.bloomberg.com/company/technology/">Bloomberg</a> for supporting my Chef community work.
---

It's been a bit since their release, but I wanted to draw attention to some new APIs in
Chef: `edit_resource` and `delete_resource`. These were both added in Chef 12.10
along with a few other friends.

[`chef-rewind`](https://github.com/thommay/chef-rewind) has been a mainstay of
the Chef ecosystem for years. It allows modifying resources from wrapper code in
a way that often allowed avoiding forks or special cases in community cookbooks.
The general idea boils down to grabbing the existing `Chef::Resource` object
from the global resource collection and then modifying it. We'll talk about
structural issues later, but the biggest stumbling block with `chef-rewind` has been
complications getting the gem installed and loaded so you can use it from
recipe code. With these new APIs in Chef 12.10, we don't need to worry about
this anymore.

# `edit_resource`

The `edit_resource` helper doesn't match the `chef-rewind` syntax exactly, but
it inherits the same concept. It comes in two variants, `edit_resource` and
`edit_resource!`. The `!` version will raise an exception if the requested
resource doesn't exist, while the non-`!` will fall back to creating the
resource for you.

As an example, let's say we want to tweak a `template` resource from a wrapper
cookbook to both reset which Erb template file it will use and to change a
variable being passed in:

```ruby
include_recipe 'communitycookbook'

edit_resource!(:template, '/etc/myapp.conf') do
  source 'other.erb'
  cookbook 'wrapper'
  variables.update(port: 8080)
end
```

In this case we opted to use the exception-raising variant so we won't keep
going if the resource isn't found. This will grab the existing resource object
and run our block against it.

We can also use `edit_resource` to power simple accumulator patterns with the
non-exception-raising variant. This version will use the block to create the
resource if it can't be found, so the first time the code runs it will create
the template and each later time it will update it:

```ruby
def my_helper(value)
  edit_resource(:template, '/etc/myapp.conf') do
    source 'myapp.erb'
    owner 'root'
    variables['values'] ||= []
    variables['values'] << value
  end
end
```

# `delete_resource`

As before, `delete_resource` comes in both exception-raising and vanilla
flavors. In this case the vanilla variant simply does nothing and returns nil
if the resource to be deleted can't be found. This replaces the `unwind` helper
from `chef-rewind`. Let's say we have a community cookbook installing something
via a system package but we want to install our own build instead.

```ruby
include 'communitycookbook'

delete_resource(:package, 'something')
package 'mycompany-something'
```

This can also be used with `edit_resource` when you want to remove already-queued
notifications.

# The Dangers Of Rewind

While these new APIs do remove the complexity of installing and loading a gem,
they don't entirely address some of the limitations `chef-rewind` has. Notably
as more and more logic moves in to custom resources, these APIs don't allow
peering inside a custom resource or provider.

There is also the general problem of using mutation of global variables, which
this effectively is. Mutable globals have been a negative cliché in programming
for decades now, and for good reason. Excessive use of this kind of "spooky
action at a distance" can lead to un-debuggable and un-reabable code.

Tread lightly.

# We Have To Go Deeper

While `edit_resource` and `delete_resource` cover the high-level functionality
from `chef-rewind`, there are some other niche helper methods worth mentioning
for low-level manipulation tasks.

## `find_resource`

The `find_resource` helper is used by `edit_resource`, and can be used to
do a "find existing or create" if you don't want to edit the resource if it
already exists.

```ruby
res = find_resource(:template, '/etc/myapp.conf') do
  source 'myapp.erb'
end
```

If no block is given, this will return `nil`. A `find_resource!` variant is
available as well, which is equivalent to the older `resources()` helper, though
a bit nicer arguments and clearer to read.

## `declare_resource`

The `declare_resource` helper extends `build_resource` to create the new
resource object and then add it to the current resource collection. This can be
useful when you want to create a resource where the type is variable somehow.

```ruby
declare_resource(:template, '/etc/myapp.conf') do
  source 'myapp.erb'
end

type = value_for_platform_family(debian: :deb, rhel: :rpm)
declare_resource(:"#{type}_package", 'myapp') do
  source "/myapp.#{type}"
end
```

## `with_run_context`

Possibly the most niche of these extra APIs, `with_run_context` allows swapping
the "current" run context for the scope of a block. You can pass it `:root` to
get the top-level run context, `:parent` to get the parent of the current
context, or a `Chef::RunContext` object. This should probably never be used from
anything except very intricate meta-code but it is available. Some examples of
potential use cases include global accumulators or definition-like macro resources.

# tl;dr

Use `edit_resource` instead of `rewind` and `delete_resource!` instead of
`unwind`. Profit.
