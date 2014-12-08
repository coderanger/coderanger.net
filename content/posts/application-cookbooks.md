---
title: "Application Cookbooks: A Tale"
date: 2014-12-08
published: false
---

Application deployment with Chef has always been a sensitive topic. Many
operations teams prefer to use Chef to deploy things like databases and web
servers, leaving in-house application code deployment to other tools like
Fabric, Capistrano, or homegrown scripts. Sometimes this is due to inertia and
existing workflows, but more often it is because using Chef for it is too
difficult.

# A Brief History

When I first started on the rewrite of the application cookbooks my goal was
simple, build a modular PaaS-ish system on top of Chef. The original
cookbook offered a few pre-baked deployment strategies that could be slightly
customized through [data bags](/data-bags/) but was overall relatively
inflexible. The deployment strategies couldn't be extended without forking
the cookbook and configuration data could only come from bags, not attributes
or other code.

With the help of [Andrea Campi](https://github.com/andreacampi), I moved the
logic for each deployment strategy into LWRPs and built a framework to knit
them together. This allowed pulling in configuration from both data bags and
node attributes, as well as developing new deployment strategies outside of the
community cookbooks. This approach has proven its worth many times over so far,
enabling many contributors to develop new deployment strategies and release
them independently.

# What Went Wrong

While small annoyances abound, I think there are two main design flaws in the
current application cookbooks. The first is that it is very much interwoven
with the deploy resource. This means it has to use the same faux-Capistrano
folder layout, and is limited by the implementation details of the deploy
resource callback system. Both of these frequently produce unexpected behavior
for new users, especially with notifications. The deploy resource also makes use
Capistrano's symlink structure for config files, which makes absolutely no
sense in a config management context where the files are being updated
automatically.

The second issue is the use of LWRPs for both the core framework and the
strategies. Due to the way LWRPs are loaded, they cannot be easily extended
or inherit from other code. This leads to an unfortunate amount of copy-pasta
when extending a deployment strategy. Additionally writing new deployment
strategies can be confusing to new users where is deviates from normal Chef
conventions, like defining callback types as actions.

# The Road Ahead

The first step in any improvement to the application framework will be to
write a new core without the deploy resource. This will allow more
flexibility with getting code to the target machine. At a minimum I would
like to see support for packages like debs and RPMs, tarball downloads, and
artifact repos like Artifactory and Nexus. Removing the deploy resource will
also allow re-imagining the deployment strategies as more traditional Chef
resources rather than simple callbacks.

My [Poise](https://github.com/poise/poise) helper library takes many of the
patterns first attempted in the application cookbooks and refines them
considerably. This will allow for much less frustrating implementations of
things like subresources and option blocks.

Moving the strategy code to normal resource classes will also allow them to be
extended and customized by users. This could be as simple as adding an extra
deployment command or as complex as changing the file layout. I
would also like to present a more diverse set of strategies to build on top of
instead of the relatively siloed stacks for single frameworks.

# How You Can Help

As many of you have seen, I'm currently running a [crowdfunding campaign on
Kickstarter](https://www.kickstarter.com/projects/coderanger/delightful-application-deployment-with-chef/)
to fund all the work I outlined above. The goal is set to allow for a month of
work, roughly broken down in to one week on each of application,
application_python, application_ruby, and application_js. If you or your
company currently uses the application cookbooks or thinks that they would
like to given the improvements mentioned, I invite you to contribute to the
campaign, [Delightful Application Deployment with Chef](https://www.kickstarter.com/projects/coderanger/delightful-application-deployment-with-chef/).

<div style="margin: auto; width: 298px; height: 82px; overflow: hidden;">
  <iframe style="display: block; margin: -300px 0 0 -1px;" frameborder="0" height="380" scrolling="no" src="https://www.kickstarter.com/projects/coderanger/delightful-application-deployment-with-chef/widget/card.html?v=2" width="300"></iframe>
</div>
