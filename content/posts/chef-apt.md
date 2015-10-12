---
title: Chef Apt Repositories
date: 2014-07-15
hire_me: Looking for help getting the most out of Chef? Check out my <a href="/training/">training</a> and <a href="/consulting/">consulting</a> services.
---

**THIS IS DEPRECATED.**

Chef Software now publishes releases via PackageCloud, which supports more
direct usage as an apt (and yum) repository. See [https://packagecloud.io/chef/stable/install](https://packagecloud.io/chef/stable/install)
for instructions on configuring the PackageCloud repositories.

**/DEPRECATION WARNING**

Do you love Chef? Do you hate `curl | bash` installations? Good news!

```bash
$ sudo apt-add-repository 'http://apt.poise.io chef-11'
$ sudo apt-key adv --keyserver hkp://pgp.mit.edu --recv 594F6D7656399B5C
$ sudo apt-get update
$ sudo apt-get install chef
...
$ chef-client --version
Chef: 11.12.8
```

There is also a `chef-10` component available if you want Chef 10.x releases.
Packages are behind the Cloudfront CDN, so installation should also be faster
than the `install.sh` script.

New releases will be added automatically, so you can handle upgrades as you do
any other package.
