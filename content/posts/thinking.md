---
title: Thinking Like A Chef
date: 2016-10-13
published: false
---

One of the first major stumbling blocks I see with new users in the Chef
community is learning to think in the same way as Chef does.

# Procedural Code

Most programming languages in the world follow an imperative or procedural
model. The concept here is simple, list a series of actions to take in order.
Each action is a step towards some kind of outcome or output that we want, but
the way we express this to the computer is just in terms of the steps
themselves. For example, a line of code might read "store the value 1 in to
variable X" or "display the value in variable Y to the console". More
functional-oriented languages move away from side effects (or at least
quarantine them as best as possible) but still, code is written by telling the
computer what to do and what order to do it in. This works out pretty well
because the real world is procedural, you can't ask for the result of a
computation without telling the computer how to get that result.

# Desired State

The general model used by Chef (and Puppet, Salt, and Ansible too) was first
developed as part of the CFEngine project. Dubbed "Promise Theory". At a high-level,
Promise Theory is a way to write code in terms of desired end state, rather than
the steps required to reach that state. The distinction is subtle, but important.
For example, "package X must be installed" versus "install package X". The former
is a stated of desired state, while the latter is an action or step.

# How To Promise Theory

To get into the specifics, Promise Theory describes a system of interlocking
actors each idempotently trying to reach their promised state. That sentence
used a lot of very jargon-y words so let's unpack it a bit. First is "actor",
the actor is the unit of desired state. In Chef, the smallest unit of desired
state is a resource. Recipes are built out of resources and roles/policies are
built out of recipes, so if well written those can be thought of a Promise-y
actors as well, but as we'll see, it is easy to stray towards the path of
recipes-as-procedural-code. For now, let's just think about resources as our actors.
Next we have "promised state" for each actor. When you write Chef code
and use a recipe, you pass it some inputs via properties (and the resource name
which is like a property with some special syntax) and actions. Promise Theory
doesn't really draw a distinction between what Chef calls resource properties
and resource actions, but we generally use properties to control data about
the resource (package version, template path) while the action determines what
overall state the resource should be in (installed, uninstalled, created, destroyed).
It is an unfortunate accident of history that what we named `action` is actually
the name of the desired state even though it sounds very procedural-y, but
so it goes. All together this data gets fed into the resource one way or another,
this defines what we want the state of the system to look like. The "promise" in
Promise Theory is the concept that the resource is like a little worker that
takes your desired state information and says "I promise I'll do my best to make
the system look like this". Sometimes an actor can't reach their desired state,
for example if the promise is "I will make package X be installed" and there is
a network outage, it might fail to fulfill its promise. Hopefully it would
succeed on the next execution, but a promise must always be best effort because
in computers, failure is always an option. The next important bit is "idempotently",
fortunately simpler than the last bits, this means that the actor does as
little as possible to achieve the desired state. Using the package example again,
this means that if the desired package is already installed, nothing happens.

# Test & Repair

The implementation of Promise Theory is generally done with a "test and repair"
model. For each actor, we test the current state of the described "thing" (imagine I'm making air quotes here) and
then select a series of steps to perform to make the current state match the
desired state. In Chef, the test phase is implemented in the `load_current_resource`/`load_current_value`
in each provider or resource, and then repair phase is the provider's action
method. You can also see echoes of this at a higher level, with Ohai testing
the current state of the system and roles/policies repairing. Overall this test
and repair model acts as an adapter between the desired state structure of
Promise Theory and the underlying procedural nature of the world. Much
of the value in Chef as a tool is that it includes many well written adapters
for common bits of state we want to manage like packages, files, and services.

# Convergence

If a system implements all of the above, it can be said to be "convergent".
Again, there are some very fuzzy-but-important distinctions though. A system can
be idempotent without being convergent. For example if we had the
pseudo code `if file X does not exist, write the current timestamp to file X`
that would be idempotent, but it can't _really_ be said to converge on a particular end
state. The true power of Chef (and any other Promise Theory-based system) is
realized when your requirements can be expressed in convergent terms.

Sometimes this isn't possible though, either because there is no way to test the
current state of an object (or if possible but prohibitively slow/complex/whatever),
or because it is usually faster to port over exiting scripts or processes in
a more procedural form. In Chef, this usually takes the form of a recipe with
a large number of `execute`-family resources in it. `execute` acts as a shim,
it's an actor in the Promise sense but is neither idempotent nor convergent on
its own. Chef offers `not_if`/`only_if` guard clauses to bolt on a bit of
idempotence when possible.

# Custom Resources

So we want to express more of our Chef code in convergent terms, what do we
do? The first, and best, approach is to create a custom resource. This lets you
take some funky, procedural bits of code and wrap them up in a test and
repair system so when you use it in a recipe, it looks and acts like a
convergent actor. Fortunately Chef has been massively simplifying the process
of writing custom resources in recent releases, so this is much less daunting
than it once was. Check out the [Chef documentation](https://docs.chef.io/custom_resources.html) for more information.

# Why?

This is all well and good, but the question still remains of why do all this in
the first place? In short, because humans are terrible at mental modeling.
With a procedural system, you need to keep a running mental map of what the
state of the system will be in after a given operation, factoring in all the
possible initial conditions. In some cases, like a Dockerfile, the initial
conditions get collapsed down to just one input, so this is at least easier, but
still easily unwieldy with larger scripts. By only requiring us to express the
end state, it reduces the mental overhead involved. This has proven time and
again to be the best known methodology for managing large systems, especially
those with substantial persistent state to consider.

# The Ontology Of Chef

Here is where I get even more philosophical. In my personal experience, the
best way to use Chef is to see your infrastructure as a set of nesting dolls.
I can wave my arms and say the word ["abstraction boundary"](/overtesting/) a
lot, but the short version is simple; build bigger actors (read: resources) out of
smaller ones. This ensures convergent, Promise-y behavior at every level. By
seeing each little resource as an actor which uses other actors, we only need
to think about/test/model the bit of logic in the actor itself and trust in each
other actor above and below in the nesting to adhere to their stated interface (i.e. their Promise).

As an example, imagine we want to deploy a Jenkins CI pipeline using Chef. This
could mean we have a `ci_pipeline` resource, and inside that several `ci_job`
resources and a `jenkins` resource, and inside `jenkins` we have a `package`
and `service` (and probably some `template`s for configuration files). Each
actor defines a clear "noun" with its own abstraction boundary and defines
the state of that noun in terms of other promises. Down at the bottom of the
nesting you'll start seeing more `shell_out!()` and `execute` creep in, but
make sure each of those follows the requirements of convergence.

While not a silver bullet, following the path of well-defined, convergent actors
for your code is much more likely to result in happiness over the long term.
