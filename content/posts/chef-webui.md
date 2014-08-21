---
title: The Future of the Chef Web UI
date: 2014-08-21
hire_me: Looking for help getting the most out of Chef? Check out my <a href="/training/">training</a> and <a href="/consulting/">consulting</a> services.
---

While not a secret, it hasn't been widely known throughout the Chef community
that the current web interface is deprecated. This was announced originally
back at the release of Chef Server 11, but little has been said since then.

# Why?

Several years ago Chef Software (then Opscode) started work on a full rewrite
of the Chef web interface. Full disclosure: I lead the team on this rewrite, so
I'm far from unbiased in all of this. The decision back then was to make sure
Enterprise Chef organizations were a first-class element of the new interface
as this was a common complaint about the old one for Hosted Chef. The downside
of this is that was that a single codebase could no longer be shared between
Enterprise Chef and Open Source Chef. This led to the new web interface being
budgeted and planned as an Enterprise Chef value-add feature.

# What Does Deprecation Mean?

Chef Software has committed to maintaining security fixes on the current
web interface through the life cycle of Chef Server 12. No feature development
is planned, and bugs are only being fixed in a "best effort" fashion. To the
best of my knowledge, Chef Software will not provide official support for the
Open Source web interface any longer. At some future point, likely Chef Server
12, the Open Source web interface will be removed from Chef Server omnibus
packages.

# What Should I Do About It?

My standing recommendation is to disable the Open Source web interface. While
Chef Software is releasing security fixes, the storm of serious Rails issues
earlier this year left many people at risk for several days at a time while
releases were prepared. Given the pending removal, it would be wise to ensure
your workflow adapts to life without the web interface.

You can disable the Open Source web interface by creating an
`/etc/chef-server/chef-server.rb` configuration file and adding
`chef_server_webui['enable'] = false` to it and then running a reconfigure:

```bash
cd /etc/chef-server
echo "chef_server_webui['enable'] = false" >> chef-server.rb
chef-server-ctl reconfigure
```

If you visit the Chef Server in a web browser you should now see an Nginx
error page.

# How Do I Get Started?

On your Chef Server machine, look in `/etc/chef-server`. You will see both a
`validation.pem` and an `admin.pem`. The validation key should be copied
to your workstation to use with `knife bootstrap` in the future. The admin
key can be used to setup your initial user account. The easiest option is to
copy it to your workstation and run:

```bash
knife client create -a -u admin -k /path/to/admin.pem yourusername
```

This will create a new admin-level client key for you. Once you have your own
client key, I recommend deleting the admin.pem key for security reasons.

# The Future

Chef Software has announced that at some future point, the Enterprise Chef web
interface will be available for free(-as-in-beer) to people with fewer than a
certain number of nodes. To the best of my knowledge that threshold has not been
announced, but it is notable that Hosted Chef's free tier is five nodes or
fewer. The Enterprise Chef web interface will still be managed as a proprietary
software project internal to Chef Software. For those that know my open source
leanings, the previous statement is not a judgment, merely a statement of fact.

Additionally Chef Software has said it would be happy to discuss turning the
existing Open Source Chef web interface over to community maintainers if any
are interested in managing the project.
