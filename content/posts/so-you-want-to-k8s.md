---
title: So You Want To Kubernetes
date: 2018-05-11
hire_me: Looking for an engineer? I'm <a href="/hire-me/">looking for a new opportunity</a>!
---

Kubernetes is slowly eating the world <sup>{{Citation needed}}</sup>. With this, we've
seen many teams dipping their toes into the container-y water. It's entirely
cliché at this point to call Kubernetes "bleeding edge", but it really is easy
to get lost or overwhelmed with all the changes happening all the time. Fortunately
there are some places that can help.

But before I jump into those, a word for people at the very start of their
Kubernetes experience. It has been a long time since I first went through the
basics of Kubernetes so it's hard to know where is the best place to begin these
days. I do generally hear good things about [Kubernetes: Up and Running](https://www.amazon.com/Kubernetes-Running-Dive-Future-Infrastructure/dp/1491935677).
I also highly recommend spinning up a cluster with either GKE or Minikube
(probably don't start with kops+AWS, it's a bit more involved) and doing toy
deployments of some simple web services. Wordpress is usually a great
application to start with, as it's small and fairly self-contained depending on
how you set it up. Start with some mix of those options and then come back to
this post when you have your sea legs.

But back to folks that are past the initial stumbling blocks and are trying to
keep up on the shifting best practices, third-party tools, and core features.

## [KubeWeekly](http://kube.news/)

If you are going to stop reading after one suggestion, [KubeWeekly](http://kube.news/)
is the one to follow. It provides a solid overview (almost) every week of things
to read, new ecosystem tools, and upcoming community events. You can subscribe
via either email or RSS.

## [LWKD](http://lwkd.info/)

KubeWeekly is a great overview of user-level things, but for those that want to
peer a little deeper, [Last Week in Kubernetes Development](http://lwkd.info/)
is a similar weekly summary of changes and decisions in the Kubernetes core
development team. This is a great way to learn about new features as they are
being added, or to see when features move along the stability track.

## [kubernetes/features](https://github.com/kubernetes/features/issues)

If you want even more visibility into the development process, the [`kubernetes/features`](https://github.com/kubernetes/features/issues)
repository acts as a central tracking point for almost all major changes in
Kubernetes. It's not as much of a firehose as following the projects themselves,
but you'll get updates on all new feature proposals or changes to existing
features. A word of warning though, you might want to set up some email filters
to hide the messages generated by the various helper bots that patrol the repo.

## [Kubernetes Podcast](https://kubernetespodcast.com/)

If you prefer to get your info via ear waves, there is a new podcast from Google
entirely about Kubernetes: [Kubernetes Podcast](https://kubernetespodcast.com/).
Only two episodes so far, but many more to come.

## [Kubernetes Slack](http://slack.k8s.io/)

Another great way to stay involved in new developments are the many SIG channels
in the [Kubernetes Slack team](http://slack.k8s.io/). I'll put aside discussions
of if Slack is a valid replacement for IRC and just say that Slack is where a
lot of conversations happen, so if you want to see those conversations, Slack
is the place to be.

## [Hangops Slack](https://signup.hangops.com/)

While the official Kubernetes Slack is home to the SIG development teams, it
can sometimes be a bit quiet for general conversation. I highly recommend the
`#kubernetes` channel in the Hangops public Slack, and it's a great place to
socialize with other ops-y folks beyond that. Even just as a lurker, its a way
to hear about new and useful tools more or less as soon as they come out, even
if a common pattern is "Has anyone heard of X?" "No, but it looks nifty".

## [Community Meeting](https://github.com/kubernetes/community/blob/master/events/community-meeting.md)

While LWKD does summarize the [community meeting](https://github.com/kubernetes/community/blob/master/events/community-meeting.md)
each week, you can also join for yourself and see first hand what direction things
are moving in. It takes place on YouTube/Zoom every Thursday at 6PM UTC, with video
recordings posted to YouTube soon thereafter.

## [/r/kubernetes](https://www.reddit.com/r/kubernetes/)

If Reddit is more your speed, the [Kubernetes subreddit](https://www.reddit.com/r/kubernetes/)
is relatively active and so far mostly free of the toxic nonsense that makes
most of Reddit a hazmat zone.

## To Infinity And Beyond!

This list is only scratching the surface of the Kubernetes community. As with
most things in open-source, when you have questions the best thing to do it to
ask them. Hopefully I've given you a jumping-off point to try and make sense of
this wild and crazy world that is Kubernetes. If you have suggestions for more
things to add, let me know [on Twitter](https://twitter.com/kantrn).
