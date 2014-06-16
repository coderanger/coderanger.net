---
date: 2014-06-15
published: false
---

# Woooooo

This is some content

```ruby
  # Fake the name
  def mod.name
    super || 'Poise'
  end

  mod.define_singleton_method(:included) do |klass|
    super(klass)
    # Pull in the main helper to cover most of the needed logic
    klass.class_exec { include Poise }
    # Resource-specific options
    if klass < Chef::Resource
      klass.poise_subresource(options[:parent], options[:parent_optional]) if options[:parent]
      klass.poise_subresource_container if options[:container]
    end
    # Add Provider-specific options here when needed
  end
```

And then without the scrollbar:

```python
def delete(self, api=None):
    """Delete this object from the server."""
    api = api or self.api
    api.api_request('DELETE', self.url)
```

## Isn't it cool

You should read
all this stuff

    Some non-code
    lines of pre text
    to test it out

# Good ol' lorem

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vitae
scelerisque eros. Sed pretium eros erat, eget placerat sem feugiat vel. Etiam
vitae magna elit. Sed eu metus molestie, semper felis convallis, sodales nisl.
Donec lobortis urna magna, vitae consequat odio luctus vitae. Sed molestie augue
quis tincidunt euismod. Nulla convallis, nunc id vestibulum vulputate, augue
lorem placerat nisl, et volutpat tellus diam rhoncus dolor.

Pellentesque tristique lacus vitae urna iaculis, vitae sagittis metus eleifend.
In et purus eget nisl interdum euismod. Pellentesque habitant morbi tristique
senectus et netus et malesuada fames ac turpis egestas. Integer congue urna
dolor, sed sollicitudin turpis vulputate nec. Mauris pulvinar est a orci
condimentum, vitae sodales lorem feugiat. Vivamus tristique leo nulla, ut
molestie lectus elementum et. In sed scelerisque risus, in aliquet nunc. Nullam
a nibh vehicula quam sagittis dictum et varius nisi. Proin lorem ligula, blandit
vel urna vitae, consequat pellentesque augue. In euismod semper urna eu tempus.
Duis vitae venenatis ligula, id tristique neque. Sed turpis lectus, rutrum non
laoreet ac, placerat id dui. Nam in erat elementum, condimentum elit in, euismod
mauris. Phasellus consectetur diam molestie, semper magna at, rutrum nisl.
Phasellus nunc diam, mollis id ipsum a, commodo placerat neque.

Mauris porta semper vulputate. Nam et mattis diam, non ultrices lectus. Sed in
elementum nibh. Duis tempor purus a malesuada convallis. Curabitur venenatis
ligula non eros aliquam porta. Nam et volutpat ligula. Aliquam nec pharetra
lorem, dapibus suscipit massa. Nulla quis lectus at elit varius rutrum. Vivamus
iaculis blandit nisi quis rhoncus. Sed volutpat dapibus justo id pretium.
Vivamus commodo consequat augue, nec accumsan elit ullamcorper ullamcorper.
Curabitur bibendum lectus ac lectus lobortis, vitae porta erat consectetur.
Proin quis neque commodo urna vulputate consequat. Pellentesque pharetra elit
justo, non rutrum massa imperdiet molestie. Sed orci dolor, dapibus eu tristique
ut, imperdiet sit amet nulla. Donec odio nulla, aliquet a est at, tincidunt
molestie ante.
