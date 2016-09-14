---
title: The Dangers of Overtesting
date: 2016-09-14
published: false
---

Tests are awesome. A huge part of the benefit of the "infrastructure as code"
movement has been that as things move into formalized code frameworks, we
can write automated tests just like for all other flavors of code. I would
be absolutely lost on a daily basis without my massive Travis-CI build matrix.

With all that said so you don't think I'm some kind of lunatic:

# **Writing more tests is not always a good idea.**

# Kinds of Tests

Focusing in on the Chef world, we have two major universes of testing. On one
side is ChefSpec for unit testing, on the other is Test Kitchen for integration
testing. Before we get into the specifics of each, let's talk about each type of
test in the abstract. If you think you're all set on what unit and integration
tests are, [skip down to the next section](#overtesting).

### Aside: Functional and Acceptance Tests

For those who noticed I left out two of the four types in the testing quadfecta.
Chef doesn't really have anything in the "functional testing" box so I usually
lump it in with integration tests and Test Kitchen. Acceptance testing is best
matched up with things like Chef's internal audit mode and the Chef Compliance
product. Both audit mode and Compliance are still relatively rare in practice so
I'll be ignoring them for the moment.

Okay, back to test theory. The fundamental building block of tests is the "code
unit". This term is intentionally a bit vague as what forms a unit can
vary between domains and projects. For Chef generally we consider recipes and
custom resources to be units for the purposes of testing. For a unit of code to
actually be useful it has to take some inputs, do _something_, and then produce
outputs. With recipes, the inputs are things like node attributes,
data bags, and search queries. With custom resources, the inputs are hopefully
limited to the resource's properties. In both cases the outputs we
care about are changes to the state of the system Chef is running on.

## Writing a Unit Test

So far so good, we've got some code in a recipe, declared it a "unit", figured
out what its input node attributes are, and figured out the desired outputs in terms of what
changes should be made to the system. In production, those input node attributes
might come from a role or a policy, but both of those would be outside of the
"unit boundary". The idea of a unit test is to test _just_ the code unit under
consideration and nothing else. If you imagine a wall around your recipe code,
everything has to be either inside or outside. For a unit test we
want to fake as much as possible outside the unit's wall so that bugs in that
code don't affect the test. This fakery takes two
main forms: fixture data and stubs. Fixtures allow inserting known, canned data
as inputs to our unit. For node attributes, this generally takes the form of
setting the attribute data in the `SoloRunner` (or `ServerRunner`) constructor
so we know exactly what values are being set and where. Stubs can also help
with getting input data to the right place, with helpers like `stub_data_bag_item`
or `stub_command`, or RSpec's [fully featured mocks and stubs support](https://www.relishapp.com/rspec/rspec-mocks/docs).

So we have our unit's inputs ready to go either through fixture data or stubs.
Next is to figure out how to analyze the outputs. In RSpec (which ChefSpec is
built on top of), this is the domain of [matchers](https://www.relishapp.com/rspec/rspec-expectations/docs).
Because we want unit tests to be isolated from each other and to run quickly, we
don't allow Chef to actually make any changes to the system. ChefSpec
automatically blocks all provider actions, and records what Chef _would have
done_. We then write some matchers against this "probably would have
happened" data that ChefSpec gathered and **bam** we have a unit test.

The key points here are that we only tested a single unit, kept that unit as
isolated as possible, and compared the outputs from known inputs.

## Writing an Integration Test

With unit tests in the bag, next up are integration tests. Test Kitchen is the
nexus point here but this involves a lot of tools. These days the actual
test code will be in either Serverspec or InSpec, but Test Kitchen acts as the
control system for managing all the various steps so it's what most people think
of.

Integration tests are where we throw unit boundaries under the bus. Here we
_want_ our tests to cross unit boundaries, so we can make sure that a given unit
correctly integrates with all the other units it uses internally. We do
still have a boundary of sorts though, a good recipe should represent
a "thing" of some kind. The ontology of configuration management is a whole different
post, but in short a recipe is a promise that when the recipe finishes running,
some kind of thing (service, CLI tool, bunch of files, whatever) will be available.
Normally this is the thing we name the cookbook/recipe after. Taking a recipe
named `apache2::default`, you can probably assume that when this recipe runs
there will be an Apache web server listening on a port. This promise
is the recipe's interface to the world, the integration test
equivalent to a unit boundary.

So to get back to writing our test, we make a `.kitchen.yml` file which tells
Test Kitchen to run our recipe, and then write some Serverspec or InSpec tests
to confirm that we did the things promised by our interface. Test Kitchen makes
us a blank VM, installs Chef, runs our recipe, and run our test code. All is
well, we've ensured that the recipe does the thing it is supposed to in a
live-fire test. It might not be 100% identical to production (especially when
you face the specter of multi-node testing, but that's yet another post), but
it's a lot closer than our unit tests. The downside is that it's also a lot
slower than a unit test. This means while you might test dozens or hundreds of
combinations of inputs in a unit test, integration tests will usually have to
pick a handful of common permutations.

<h2><a class="no-underline" href="#overtesting" name="overtesting">What Do You Mean, Overtesting?</a></h2>

That all sounds great, right? Testing will set us free. What is this "overtesting"
thing?

Let's look at a simple example of a Chef recipe:

```ruby
package %w{python python-dev}

template "/etc/myapp.conf" do
  source "myapp.conf.erb"
end
```

Nothing too fancy, installing some packages and writing out a template file.
Let's write a unit test for this, because we've heard that's the thing to do!

```ruby
describe "myapp" do
  let(:chef_run) do
    ChefSpec::SoloRunner.converge("myapp")
  end

  it do
    expect(chef_run).to install_package(["python", "python-dev"])
    expect(chef_run).to create_template("/etc/myapp.conf")
  end
end
```

Okay, that wasn't so bad. The problem is subtle. If we think about our unit
(recipe), there is basically no logic in it. The unit test is 99% checking that
Chef itself is working, not that our code is working. In fact given only the
test, you could probably rewrite the recipe from scratch. This one-to-one
correspondence between unit code and test code is a strong indicator that you
might not actually have enough logic to justify a unit test.

Okay, you're probably saying that seems reasonable but what's the harm? After
all, that kind of test can be nice for catching syntax errors and typos. The
problem is that writing tests isn't free. It takes time and effort to manage them,
and this doesn't diminish with time. If every change in a recipe requires a one-to-one
change in the test code, how long will it be until someone comments out the
tests? This low return-on-investment for time spent on unit test code is the
biggest overtesting problem in the Chef community. People spend lots of time
on unit tests that in the end deliver very little value because they simply don't
have much to test in the first place. This can lead to "testing burnout",
where all testing is painted with the same brush of "not worth it".
And to the issue of catching typos, I would recommend checking out linter tools
like [RuboCop](https://rubocop.readthedocs.io/en/latest/) or
[FoodCritic](http://foodcritic.io/). They can fit this need with a tiny fraction
of the time spent on upkeep.

So that's unit tests, but what about integration tests? Fortunately the story
there is better. Test Kitchen integration tests have a much higher return-on-investment
for the time you put in, but I still see a lot people writing overly complex
test code. In both unit and integration tests, the tests should be checking only
the things we promised as the interface to the outside world. Put another way,
test code should care about results, not how you got them. Going back to our
`apache2` recipe, we don't want to do things like check if a certain package
is installed or certain process is running. If the interface we promised is
"this recipe will result in an Apache server listening on localhost:80" then
just about the only thing we should be testing is `command("curl localhost")`
and leave it at that. Sometimes you'll want a few other things like checking
file permissions for security reasons, but what packages are or are not installed
doesn't matter. If that HTTP request succeeds then we have fulfilled our
interface, and it isn't the job of the test code to care about how that happened.

# When Are Unit Tests A Good Idea?

So if I'm telling you to write drastically fewer unit tests and much shorter
integration tests, when is ChefSpec a good idea? One of the great things about
Chef is the flexibility we have from the DSL being straight up Ruby code at
heart. While this does provide ample room for [footguns](https://github.com/poise/application/blob/1.0.0/recipes/rails.rb), some level of control
logic in a recipe is often the best path to get something working. With the
simple, linear recipe we saw above there are no inputs and no branches so there
is only one possible way that code can execute. As you start adding inputs
though node attributes or other sources, you often also end up with things like
`if` conditionals or `each` loops. With each bit of logic, the possible ways a
unit can execute goes up exponentially. While having too much logic in a recipe
is probably asking for future-you to be sad, this is really where ChefSpec shines.
Because it is so much faster than an integration test, you can try out a larger
number of possible inputs. You are still unlikely to be able to try them all for
anything beyond very small recipes, but the more branch and loop combinations
you test, the more certain you are that things will pass when you get to
integration tests and then real usage after that.

# tl;dr

* Start with integration tests and Test Kitchen.
* Only write unit tests when your recipe/resource has actual logic to test.
* Don't write tests for checking Ruby syntax or checking that Chef works.
* Write tests that check only your declared interface.
* Be aware of the RoI of writing tests and don't use them as a magic bullet.
