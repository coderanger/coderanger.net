---
layout: post
title: Arrays and Chef Attributes
---

A conversation with a friend today reminded me how easy it is to find unexpected behavior with Chef attributes when using array values. Arrays are good for many things, and are often a seemingly natural fit to describe server values. The example my friend was having issues with was:

{% highlight ruby %}
default['chruby']['rubies'] = ['jruby', '1.9.3', '2.0.0']
...
node['chruby']['rubies'].each do |ruby|
    ...
end
{% endhighlight %}

This is simple, consise, and relatively unambiguous to the reader; all hallmarks of good code. There is a sinister side though, how do you cope with merges on an array? Chef attributes exist in a [nested structure](http://docs.opscode.com/essentials_cookbook_attribute_files.html#attribute-precedence), where different sources and precedence levels are [merged together](https://github.com/opscode/chef/blob/master/lib/chef/mixin/deep_merge.rb) to form the final attributes that your recipes run against. With hashes, this merge is relatively straight forward, if both the original and override values are hashes they are recursively merged together all the way down. This logic is less clear on arrays though. I will skip the history lesson and just say the current behavior is that with different precedence levels, array values are simply overridden, but on the same level they set-unioned together. This behavior is often unexpected and can lead to subtle errors.

## A better way

In light of these confusing and unhelpful semantics for arrays, I generally recommend people avoid them. Most uses of arrays in Chef code are situations where order doesn't actually matter. In the case of the above example, what we actually have is a set of three boolean flags. This leads us to a somewhat more verbose, but also more flexible system:

{% highlight ruby %}
default['chruby']['rubies'] = {'jruby' => true, '1.9.3' => true, '2.0.0' => true}
...
node['chruby']['rubies'].each do |ruby, flag|
  if flag
    ...
  end
end
{% endhighlight %}

What does this gain us? Well for one the semantics of overriding are clearer. You can also either add or remove a value at any point in the tree:

{% highlight ruby %}
override_attributes({
  'chruby' => {
    'rubies' => {
      'jruby' => false,
      '1.8.7' => true
    }
  }
})
{% endhighlight %}

This both clarifies your existing code, and allows flexibility you may need in the future. Sometimes you really do just want an array in the end, perhaps to pass to an external library, or to render into a template:

{% highlight ruby %}
node['chruby']['rubies'].inject([]) {|memo, (key, value)| memo << key if value; memo}
{% endhighlight %}

## But what about order?

So one crucial difference between using an array and a hash of boolean flags is a loss of ordering. Ruby does track the insertion order in hashes, so usually the final order of keys will follow the default/normal/override ordering that attributes themselves use, but sometimes this is not enough. In these cases we can instead use a hash of weight values, which we sort on afterwards:

{% highlight ruby %}
default['chruby']['rubies'] = {'jruby' => 100, '1.9.3' => 50, '2.0.0' => 50}
...
node['chruby']['rubies'].inject([]) {|memo, (key, value)| memo << key if value; memo} \
.sort_by {|key| node['chruby']['rubies'][key]}.each do |ruby|
  ...
end
{% endhighlight %}

This keeps all the earlier benefits of being able to change or remove values at any point in the precedence tree, while still getting consistent ordering.

All in all these patterns do involve both a little bit more Ruby code, and some more careful planning, however the immediate benefits make it worth a look and your maintenance engineers will thank you in six months.
