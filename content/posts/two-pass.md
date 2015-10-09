---
title: Chef's Two Pass Model
date: 2015-10-09
hire_me: Like this Chef tip? Hiring Chef engineers or tool developers? I'm looking for a new team! Check out my <a href="/looking-for-group/">Looking for Group</a> post for details.
---

A common source of bugs in Chef code for new and experience users alike is Chef's
two-pass (or two-phase) execution model. I would like to provide a quick overview
of this system and how it can impact your code.

# Phases

Chef's loading process can be broadly split into four phases:

1. Load
2. Compile
3. Converge
4. Cleanup

Of these, the compile and converge phases make up the bulk of the work and are
"execution phases". When we talk about the two-pass or two-phase system, it is
these two phases we are talking about, but let's look at each phase in turn.

# Load

During the load phase Chef syncs all the needed cookbooks with the Chef Server
if one is being used. Each of the five types of support files are loaded in order:

1. `libraries/`
2. `attributes/`
3. `resources/`
4. `providers/`
5. `definitions/`

All of the files of each type are loaded for all cookbooks before moving on to the
next type. Loading happens in sorted (topographic) order with respect to cookbook
dependencies and the run list order, and alphabetical order within each cookbook.

This means if cookbook B depends on cookbook A, we might see a load order like:

1. `a/libraries/default.rb` (library files are first, A is sorted before B because of dependency)
2. `b/libraries/default.rb` (then B's library files)
3. `a/attributes/default.rb` (attribute files are next, again A is first)
4. `b/attributes/default.rb` (and B is second because B depends on A)
5. `b/resources/first.rb` (A has no resources files so we skip to B, `first` is alphabetically before `second`)
6. `b/resources/second.rb`

By the time the loading phase is complete, the node object is fully populated,
all custom resources are available for use, and we can move on to the compile
phase.

# Compile

The compile phase is first of the execution phases. The goal of the compile
phase is to go from recipe source code to in-memory representations of resource
objects. At this point we have taken the node's run list and fully expanded it,
so any roles are replaced by their constituent recipes until all we have is an
ordered list of recipes to run. We will run each of those recipes in order, and
if no errors are raised we'll move on to the next phase.

This is where the major "gotcha" of the execution model comes in. Take some
example recipe code like:

```ruby
file '/foo' do
  content 'bar'
end
```

Assuming that recipe is in the run list, or is run via `include_recipe` from
something else being compiled, that code will run. However running the code
does not actually write any content to file. All it does is create a
`Chef::Resource::File` object with all of the data expressed in the recipe code
and add that object to the resource collection. This is true of all resources
in the DSL, running (compiling) the recipe file is just queuing up resources in
the resource collection. No changes to the system should happen until the
converge phase. This also means that any Ruby code in the file not explicitly
delayed (`ruby_block`, `lazy`, `not_if`/`only_if`) is run when the file is run,
during the compile phase.

# Converge

Once the compile phase completes we have a resource collection that is fully
loaded and ready to go. This is an array of resource objects that represent
the data from our recipes. The majority of the converge phase can be seen as:

```ruby
resource_collection.each do |resource|
  resource.run_action(resource.action)
end
```

There is a little more complexity to deal with things like notifications, but
that is the heart of it; loop over each resource and run the requested action.
This is where provider classes get used, `run_action` creates a provider
instance internally and runs the action code from the provider. Those methods
are what actually do all the interesting things like writing files, installing
packages, etc.

# Cleanup

With the compile phase finished, we just have a few cleanup steps left to
process. This includes things like running handler plugins, saving the node
state back up to the Chef Server, and sending data to the Chef Analytics server
if being used.

# Bad Code

A concrete example of the kind of errors that can creep in due to the execution
model:

```ruby
file '/foo' do
  content 'bar'
end

if File.exist?('/foo')
  execute 'myapp /foo'
end
```

Here we have two resources and an `if` statement. The bug happens because the
`File.exist?` check will run at compile time, and even though it is after the
`file` resource, at that point in the execution the file hasn't actually been
written yet. The solution in this case is to use an `only_if` guard like:

```ruby
file '/foo' do
  content 'bar'
end

execute 'myapp /foo' do
  only_if { File.exist?('/foo') }
end
```

As `only_if` guard clauses (and `lazy` property values and the block on
`ruby_block`) is run during the converge phase, this will more often behave as
the author expects.

# <a class="no-underline" href="#tldr" name="tldr">tl;dr</a>

First all recipes on the run list are compiled in to resources in the resource
collection, then all resources in the collection are converged.

Any code outside `lazy`, `only_if`/`not_if`, or a `ruby_block`'s `block`
property is run at compile time, which is before any resource runs its actions.
