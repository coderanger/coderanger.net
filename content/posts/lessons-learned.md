---
title: Lessons Learned From Two Years Of Kubernetes
date: 2020-06-05
title_font_size: 20px
list_font_size: 20px
---

As I come up for air after a few years of running an infrastructure team at Ridecell, I wanted to record some thoughts and lessons I’ve learned.

1. [Kubernetes Is Not Just Hype](#kubernetes-is-not-just-hype)
2. [Traefik + Cert-Manager + Ext-DNS Is Great](#traefik--cert-manager--ext-dns-is-great)
3. [Prometheus Rocks, Thanos Is Not Overkill](#prometheus-rocks-thanos-is-not-overkill)
4. [GitOps Is The Way](#gitops-is-the-way)
5. [You Should Write More Operators](#you-should-write-more-operators)
6. [Secrets Management Is Still Hard](#secrets-management-is-still-hard)
7. [Native CI And Log Analysis Are Still Open Questions](#native-ci-and-log-analysis-are-still-open-questions)

## Kubernetes Is Not Just Hype

I’ve been active in the [Kubernetes](kubernetes.io/) world for a long time so this wasn’t unexpected, but when something has this much hype train around it, it’s always good to double check. Over two years, my team completed a total migration from Ansible+Terraform to pure Kubernetes, and in the process more than tripled our deployment rate while cutting deployment errors to “I can’t remember the last time we had one” levels. We also improved operational visibility, lots of boring-but-critical automation tasks, and mean time to recovery on infrastructure outages.

Kubernetes is not magic, but it is an extremely powerful tool when used well by a team that knows it.

## Traefik + Cert-Manager + Ext-DNS Is Great

The trio of [Traefik](https://containo.us/traefik/) as an Ingress Controller, [Cert-Manager](https://cert-manager.io/docs/) for generating certificates with LetsEncrypt, and [External-DNS](https://github.com/kubernetes-incubator/external-dns) for managing edge DNS records makes HTTP routing and management smooth like butter. I’ve been fairly critical of Traefik 2.0’s choice to remove a lot 1.x annotation features however they have finally returned in 2.2, albeit in a different form. As an edge proxy, Traefik is a solid choice with great metrics integration, the fewest moving pieces of any Ingress Controller, and a responsive (if sometimes a bit K8s-clueless) dev team. Cert-Manager is a fantastic tool to use with any ingress approach. If you do TLS in your Kubernetes cluster and aren’t already using it, go check it out right now. External-DNS gets less glory than the other two pieces, but is no less important for automating the otherwise error-prone step of ensuring DNS records match reality.

If anything, these tools might actually make it too easy to set up new HTTPS endpoints. Over the years we ended up with dozens of unique certificates which created a lot of noise in things like Cert Transparency searches and LetsEncrypt’s own cert expiration warnings. Next time I will carefully consider which hostnames can be part of a globally configured wildcard certificate to reduce the total number of certificates in play.

## Prometheus Rocks, Thanos Is Not Overkill

This was my first time using [Prometheus](https://prometheus.io/) as the primary metrics system and it lived up to its reputation as the premier tool in that space. We went with [Prometheus-Operator](https://github.com/coreos/prometheus-operator) for managing it and that was also a great choice, making it a lot easier to distribute the scrape and rule configs into the applications that needed them. One thing I would do differently is using [Thanos](https://thanos.io/) from the beginning. I originally thought it would be overkill at first, but it was very easy to set up and was hugely helpful on both cross-region queries and reduced resource usage in Prometheus, even if we didn’t jump directly to an active-active HA setup.

The biggest frustration I have with this part of the stack is [Grafana](https://grafana.com/) data management, how to store and organize the dashboards. There’s been a huge growth of tools for managing dashboards as YAML files, JSON files, Kubernetes custom objects, and probably anything else you can think of. But the underlying problem is still that it’s difficult to author a dashboard from scratch in any of those tools because Grafana has a million different config options and panel modes and whatnot. We ended up treating it as a stateful system as doing all dashboard management in-band, but I don’t really love that solution. Is there a workflow here that can be better?

## GitOps Is The Way

If you use Kubernetes, you should be practicing [GitOps](https://www.gitops.tech/). There’s a wide range of tooling options, the simplest being a job in your existing CI system that runs `kubectl apply` all the way up to dedicated systems like [ArgoCD](https://argoproj.github.io/argo-cd/) and [Flux](https://docs.fluxcd.io/). I am firmly in the ArgoCD camp though, it was a solid tool to start with and over the years it has only gotten better. Just this week the first release is up for gitops-engine, putting ArgoCD and Flux both on a shared underlying system so it can get better even faster now, and if you don’t like the workflows of either of those tools it is now even easier to build something new. A few months ago we had an accidental disaster recovery game-day from someone inadvertently deleting most of the namespaces in a test cluster and thanks to careful GitOps-ing our recovery was `make apply` in the bootstrap repo and wait for the system to rebuild itself. That said, some Velero backups are important too for stateful data that can’t live in git (eg. cert-manager’s certs, it could reissue everything but you might hit rate limits from LetsEncrypt).

The biggest issue we had was with the choice to keep most of our core infrastructure in a single repo. I still think a single repo is the right design there, but I would divide things into different ArgoCD applications inside that rather than just having the one “infra” app. Having one app led to long(er) converge times and noisy UIs and had little benefit once we got used to splitting up our Kustomize definitions correctly.

## You Should Write More Operators

I went in hard on custom operators from the start and we were hugely successful with them. We started with one custom resource and controller for deploying our main web application and slowly branched out to all the other automation needed for that application and others. Using plain Kustomize and ArgoCD for simple infrastructure services worked great, but we would reach for an operator any time we either wanted to control external things (ex. creating an AWS IAM role from Kubernetes, to be used via kiam) or when we needed some level of state machine for the thing (ex. Django application deployment with SQL migrations). As part of this we also built a very thorough test suite for all our custom objects and controllers which greatly improved operational stability and our own certainty that the system worked correctly.

There’s a lot more options for building operators these days, but I’m still very happy with [kubebuilder](https://book.kubebuilder.io/) (though to be fair, we did substantially modify the project structure over time so it’s more fair to say it was using controller-runtime and controller-tools than kubebuilder itself). Whatever language and framework you feel most comfortable with, there is probably an operator toolkit available and you should absolutely use it.

## Secrets Management Is Still Hard

Kubernetes has its own Secret object for managing secret data at runtime, using it with containers or with other objects, all that jazz. And that system works fine. But the long-term workflow for secrets is still kind of a mess. Committing a raw Secret to Git is bad for many reasons I hopefully don’t need to list, so how do we manage these objects? My solution was to develop a custom EncryptedSecret type which encrypted each value using AWS KMS along with a controller running in Kubernetes to decrypt back to a normal Secret so things work like usual, and a command line tool for the decrypt-edit-reencrypt cycle. Using KMS meant we could do access control via IAM rules restricting KMS key use, and encrypting only the values left the files reasonably diff-able. There are now some community operators based around [Mozilla Sops](https://github.com/mozilla/sops) that offer roughly the same workflow, though Sops is a little bit more frustrating on the local edit workflow. Overall this space still needs a lot of work, people should be expecting a workflow that is auditable, versioned, and code-reviewable like for everything else in GitOps land.

As a related issue, the weaknesses of Kubernetes’ RBAC model are most apparent with Secrets. In almost all cases, the Secret being used for a thing must be in the same namespace as the thing using it, which often means Secrets for a lot of different things end up in the same namespace (database passwords, vendor API tokens, TLS certs) and if you want to give someone (or something, same issue applies to operators) access to one, they get access to all. Keep your namespaces as small as possible. Anything that can go in its own namespace, do it. Your RBAC policies will thank you later.

## Native CI And Log Analysis Are Still Open Questions

Two big ecosystems holes I ran into are CI and log analysis. There’s lot of CI systems that deploy on Kubernetes, Jenkins, Concourse, Buildkite, etc. But there’s very few that feel like native solutions at all. [JenkinsX](https://jenkins-x.io/) is probably the closest to a native experience but it’s built on a mountain of complexity that I find very unfortunate. [Prow](https://github.com/kubernetes/test-infra/tree/master/prow) itself is also very native but also very bespoke so not a super easy thing to get started with. [Tekton Pipelines](https://tekton.dev/) and [Argo Workflows](https://argoproj.github.io/docs/argo/readme.html) both have the low-level plumbing in place for a native CI system but finding a way to expose that to my development teams never got beyond a theoretical operator. Argo-CI seems to be abandoned, but the Tekton team seems to be actively pursuing this use case so I’m hopeful for some improvement there.

Log collection is mostly a solved problem, with the community centralizing on [Fluent Bit](https://fluentbit.io/) as a DaemonSet shipping to some [Fluentd](https://www.fluentd.org/) pods which then send onwards to whatever systems you use for storage and analysis. On the storage side we’ve got [ElasticSearch](https://www.elastic.co/elasticsearch/) and [Loki](https://grafana.com/oss/loki/) as the main open contenders, each with their own analysis frontend ([Kibana](https://www.elastic.co/kibana) and [Grafana](https://grafana.com/)). It’s mostly that last part that seems to still mostly be the source of my frustration. Kibana has been around much longer and has a good spread of analysis features, but you really have to use the commercial version to get even basic operational stuff like user authentication and per-user permissions are still very fuzzy. Loki is much newer and has even less in the way of analysis tools (substring searching and per-line tag searching) and nothing for permissions so far. If you’re careful to ensure that all log output is safe to be seen by all engineers this can be okay, but be ready for some pointed questions on your SOC/PCI/etc audits.

## In Closing

Kubernetes is not the turnkey solution many pitch it to be, but with some careful engineering and a phenomenal community ecosystem, it can be a platform second to none. Take the time to learn each of the underlying components and you’ll be well on your way to container happiness, hopefully avoiding a few of my mistakes on the way.
