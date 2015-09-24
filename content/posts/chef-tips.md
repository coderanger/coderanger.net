---
title: Eight Short Chef Tips
date: 2015-09-24
hire_me: Like these Chef tips? Hiring Chef engineers or tool developers? I'm looking for a new team! Check out my <a href="/looking-for-group/">Looking for Group</a> post for details.
---

As a perk for my Kickstarter backers, I sent postcards with some helpful Chef
tips. While those cards will forever be collectors items, I want to share the
tips with you all as they have proven a useful reference for new Chef users!

<h2><a class="no-underline" href="#1" name="1">Tip #1: platform? and platform_family?</a></h2>

![Tip 1: platform? and platform_family?](/img/chef_tips/sm_1_front.jpg)

In recipe code, you can use platform? and platform_family? to examine the
current system:

```ruby
if platform?('centos')
  execute 'scl enable ruby200 "ruby install.rb"'
end

if platform_family?('debian')
  package 'openssl-dev'
end

file '/etc/motd' do
  user 'root'
  content 'Welcome!'
  only_if do
    platform?('ubuntu')
  end
end
```


<h2><a class="no-underline" href="#2" name="2">Tip #2: Lazy Resource Attributes</a></h2>

![Tip 2: Lazy Resource Attributes](/img/chef_tips/sm_2_front.jpg)

Using the lazy helper with resource attributes you can delay computing the value
until the converge phase:

```ruby
package 'openssl'

file '/etc/ssl/version' do
  extend Chef::Mixin::ShellOut
  content lazy {
    shell_out!('openssl version').stdout
  }
end
```


<h2><a class="no-underline" href="#3" name="3">Tip #3: Mini Recipe DSLs</a></h2>

![Tip 3: Mini Recipe DSLs](/img/chef_tips/sm_3_front.jpg)

Add often used values or snippets of code to your recipe as DSL methods:

```ruby
# libraries/default.rb
module MyDSL
  def api_url
    "https://#{node['api_host']}:#{node['api_port']}"
  end
end
```

And then add it to the recipe:

```ruby
extend MyDSL

log "url is #{api_url}"
```

Or add it to a single resource:

```ruby
template '/etc/app.conf' do
  extend MyDSL
  variables url: api_url
end
```


<h2><a class="no-underline" href="#4" name="4">Tip #4: Chef's HTTP Client</a></h2>

![Tip 4: Chef's HTTP Client](/img/chef_tips/sm_4_front.jpg)

Chef has an `http_request` resource for making fire-and-forget API calls, but
sometimes you want to fetch some data and use it:

```ruby
template '/etc/app.conf' do
  variables({
    my_id: Chef::HTTP.new('https://cmdb/').get('/')
  })
end
```

This automatically gets the same TLS verification settings as the rest of
chef-client and handles HTTP redirections.

Other available methods:

```ruby
get(path, [headers])
post(path, data, [headers])
head(path, [headers])
```


<h2><a class="no-underline" href="#5" name="5">Tip #5: Use %{} for Derived Attributes</a></h2>

![Tip 5: Use %{} for Derived Attributes](/img/chef_tips/sm_5_front.jpg)

Using one node attribute in the value of another is convenient in many cases:

```ruby
default['version'] = '1.0'
default['url'] = "https://download/#{node['version']}"
```

However this can cause problems when trying to override just the first, as the
value of the second has already been created. Instead we can use % string
formatting to delay  interpolation until after all  overrides are processed:

```ruby
# attributes/default.rb
default['version'] = '1.0'
default['url'] = "https://download/%{version}"
# recipes/default.rb
remote_file '/tmp/app.zip' do
  source node['url'] % {
    version: node['version']
  }
end
```


<h2><a class="no-underline" href="#6" name="6">Tip #6: Custom Template Sources</a></h2>

![Tip 6: Custom Template Sources](/img/chef_tips/sm_6_front.jpg)

By default Chef lets you easily add per-host or per-OS overrides for template
source files, but you can add your own categories:

```ruby
template '/etc/app.conf' do
  source [
    "host-#{node['fqdn']}/app.erb",
    "app-#{node['app_name']}/app.erb",
    "default/app.erb",
    "app.erb",
  ]
end
```

You could then put a per-app override in “app-foo/app.erb” and Chef will pick it
up. Each item in the list is tried and the first one that exists will be used.
This works with cookbook_file as well.


<h2><a class="no-underline" href="#7" name="7">Tip #7: Access Chef Data From Scripts</a></h2>

![Tip 7: Access Chef Data From Scripts](/img/chef_tips/sm_7_front.jpg)

Chef is an awesome configuration management tool to start with. Adding Chef
Server gives you nice workflow advantages and gives you an API for all your Chef
data. Nodes, roles, bags, and more are available via an HTTP call:

```ruby
# Ruby: chef-api
ChefAPI.configure do |c|
  c.endpoint = 'https://...'
  c.client = 'name'
  c.key = '~/.chef/name.pem'
end
include ChefAPI::Resource
Node.each do |node|
  puts node.name
end
```

```python
# Python: PyChef
import chef
from chef import Node
api = chef.autoconfigure()
for node in Node.list(api):
  print node.name
```


<h2><a class="no-underline" href="#8" name="8">Tip #8: Debug Chef Attributes</a></h2>

![Tip 8: Debug Chef Attributes](/img/chef_tips/sm_8_front.jpg)

Sometimes it can be unclear at which precedence level a node attribute is being
set. The `debug_value` function helps shed some light on this:

```ruby
require 'pp'
# For node['foo']['bar']
pp node.debug_value('foo', 'bar')
# Output
[["set_unless_enabled?", false],
 ["default", "attributes default"],
 ["env_default", :not_present],
 ["role_default", "role default"],
 ["force_default", :not_present],
 ["normal", "attributes normal"],
 ["override", "attr override"],
 ["role_override", "role override"],
 ["env_override", :not_present],
 ["force_override", :not_present],
 ["automatic", :not_present]]
```
