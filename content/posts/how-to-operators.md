---
title: How To Write An Operator For Anything
date: 2020-06-08
title_font_size: 24px
list_font_size: 24px
---

I have been a very vocal fan of custom operators as a hugely important tool for success with Kubernetes. They are a fuller realization of the same design goals as the Chef/Puppet/Ansible/Salt config management world but freed from the workflow requirements of those tools as the only fundamental need is to be some kind of daemon that talks to the Kubernetes API. This allows the flexibility and customizability these tools always lacked, but with those wide open possibilities comes difficulties for new users just getting started. So here is a four step process to write an operator for any task.

This will not cover any particular library or framework, but I do want to put in a single shoutout for [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) as my personal choice for a starting point. If Go isn’t your cup of tea, there are a ton of other options though, I’ll summarize a few major ones at the end.

## Step 0 - What Is An Operator

If you’ve already worked with Kubernetes operators, you can skip down to step 1, but for any new folks in the audience: an operator is a combination of two Kubernetes features, custom API object types and custom controllers which use the API to monitor for changes to those objects and then use that data to go automate something, usually some kind of deployment but not always.

One operator may include many types and controllers but to keep things simple let’s just start with one of each. The custom type (also called a custom resource definition or CRD) is a way to tell the Kubernetes API system that you have this new kind of object you want to store. Once you give it a schema and some metadata, then just like there is a `v1/ConfigMap` or `appsv1/Deployment`, there will be a `youv1/YourThing` and you can use it just like the built-in types. As you get more fancy, this can even mean operators automating other operators, once the custom type is registered with the API it really is as if it was any other object type in Kubernetes. With the custom type in place, the other piece is a controller to provide some behavior for the operator. In rare cases you can even have just the controller if the only objects you want to work with already exist. We’ll talk about the theory of control loops in a bit but the core idea is to watch the API for any changes in objects you care about, fetch those changes, do some kind of action if those changes require it, repeat forever.

Operators come in all shapes and sizes but that is the general idea. The end goal is always to distill some operational expertise into software so it can be repeatable, testable, and sharable. A good operator is like an executable version of your ops runbook.

## Step 1 - Do The Thing Manually

The first step in any operational automation is always having a firm grasp on how to do it by hand. For most operators, this means writing some YAML manifests for deploying your service manually. Note down any points in the process where you need some kind of special manual step or `kubectl exec`, but just get it working. If there’s already manifests (or a Helm chart), that can be a great place to start. Read through all the pieces and try using it yourself until you know how all the bits interact.

## Step 2 - Draw A State Machine

A state machine is an abstract representation of all the states a thing can be in (Deploying, Ready, Running Migrations, Failed, etc) along with how those states interact with each other. In very simple cases there are just two states, NotDeployed and Deployed, though if your state machine is that simple then perhaps an operator is overkill and the plain manifests are enough. In a lot of cases there are more steps though, some kind of one-time initialization or database schema changes to run or version upgrades to handle.

Once you have worked out a manual approach, think through all the states your service or object can be in and what actions are required to move from each state to the next. Sometimes those actions will be “wait for X to be up and responding”, sometimes they will be more complex like “if the app version does not match the last version for which migrations were run, switch to state Migrating”. I find it helpful to actually sketch this out on paper or draw.io so the whole team can be on the same page about this state machine as it will form the skeleton of your operator's structure.

## Step 3 - Model Your Configuration

Once you have a feel for the operational flow you want to automate, the next phase is to examine what configuration you want to expose to the end user and how it will be connected to the thing being automated. Sometimes the deployment handling for a service is relatively simple but runtime configuration management is the more important piece of the operator, prometheus-operator being a great example of this. In Kubernetes, this generally means sketching out your custom object type or types. I usually do this very directly, by writing what I want the eventual YAML to look like for some common use cases and then working backwards to convert that into Go structs or whatever else you need.

It’s not specifically required, but almost all Kubernetes objects follow the pattern of having two substructs at the root of the object: Spec (short for Specification) and Status. Roughly speaking you can think of your operator as a function, and the Spec struct is the input to the function while the Status is the output.

There is a constant tension in application automation between providing a simplified user experience for complex software and still allowing experts to do expert things. The right balance will be different for each tool and team but at least think about how to offer both good defaults for a Kubernetes use case while also letting people override them when needed. Often this means modelling the most useful config options or flags in your custom object and providing an override along the lines of “if you want to write some custom additions to the config file, put them in a config map and put the name here”.

## An Aside - Promise Theory

I’ve discussed Promise Theory [many times before](/thinking/) but it bears some repeating. The main idea of Promise Theory is to model a process as a series of separate processes (actors) each of which takes a request like “please make the world look like X” and then it spins in a loop doing its best to accomplish that goal. We touched on controllers a bit before, they are a very literal implementation of Promise Theory, the controller is an actor that takes a request in the form of your custom type and promises to try and make reality match whatever is in the spec.

## Step 4 - Decompose Into Actors

Once you have your manual logic, state machine, and configuration schema it's time to work out how to think through the problem in convergent, Promise Theory-y terms. Your manual steps probably read like a shell script, do this then that then that. While some simple cases can just be wrapped in a controller and called done, it is usually necessary to reframe the process as a series of goals rather than steps, where the actions are how you move between goals. This maps back to other Kubernetes objects very well, you don’t “do a deployment” in Kubernetes, you set a desired state of “deployment matching this specification exists and is running” (that is what a Deployment object does).

You will still sometimes have procedural bits around the edges, usually in the places you are either running explicitly sequenced steps like SQL migrations or when you are talking to external systems like your cloud provider API, but try to think of those in convergent terms. That usually means some code like `get current X; if current X != desired X { change x to match desired }; repeat`. This is the same thing the core Kubernetes objects are doing under the hood, they just present you a nicely convergent view rather than you having to worry about all the individual details and steps that go on, just as you will be doing for the end users of your operator.

While your controller as a whole is a Promise Theory actor, as your code gets bigger it can often be helpful to break the control loop itself into multiple smaller convergent chunks that happen to run together. Always keep an eye towards how you will test your operator, large reconcile functions can explode in combinatorial complexity which makes unit testing much harder. Similarly don’t be afraid to break functionality into multiple types and controllers when it makes sense, one controller using another (indirectly) is encouraged and can help keep your bigger controllers much more debuggable in production.

## Some Tools To Investigate

I hope this has given you a growing desire to try things out yourself. Here’s a few frameworks to check out that help get started even faster by handling a lot of the basics for you, so you can focus on your types and controllers rather than API plumbing.

1. [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)
2. [Operator-SDK](https://github.com/operator-framework/operator-sdk)
3. [Kopf](https://github.com/zalando-incubator/kopf)
4. [KUDO](https://kudo.dev/)
5. [Metacontroller](https://metacontroller.app/)

If none of those match the language or toolkit you would like to use, you can also drop down a level and use a plain Kubernetes API client, which exists for pretty much every ecosystem. This will usually mean a bit more boilerplate, but once you get started it will be just as good.
