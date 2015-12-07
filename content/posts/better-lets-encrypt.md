---
title: A Better Let's Encrypt Client
date: 2015-12-07
---

[Let's Encrypt](https://letsencrypt.org/) recently entered public beta, providing
free TLS certificates for everyone, forever. We should pause for a moment to
consider how important that statement is. Okay, still with me? Let's Encrypt
works by verifying that you control the domain you are requesting a certificate
for by giving you a random token and then making a request against the domain
and expecting to get that token back. This is commonly called a Domain Validated
(DV) or Domain Control Validated (DCV) certificate, and has been the norm for
TLS certificate authorities for a while now. A new thing with Let's Encrypt is
their DV process is actually fully specified in a protocol called [ACME](https://tools.ietf.org/html/draft-ietf-acme-acme-01),
though Let's Encrypt doesn't currently implement the full ACME spec.

# What I Want

I write tools for a living. This means I write software that gets used in wide
variety of environments and use cases, and I have to be very careful about the
assumptions I make. What I want out of Let's Encrypt (and future ACME-supporting
certificate issuers) is something like this (using Chef's DSL as an example):

```ruby
tls_certificate '/etc/something/cert.pem' do
  hostname 'example.com'
end
```

An abstract description of where to put the certificate and what hostname to
request it for, and then my code takes over and handles all the details so the
user doesn't need to know or care.

In building this I need to plan for some restrictions on what I can and can't do.
In most situations, something will already be listening on ports 80 and 443, and
I won't know what it is. It might be Apache, or Nginx, or HAProxy, etc etc. As
I don't know what software is bound to those ports, I also don't know how it is
configured and can't assume I can serve files through it. It might be a dedicated
proxy service or webapp container with no capability to serve files, for example.

To summarize:

* Can't listen on ports 80 or 443.
* Can't serve files or interact with whatever is already on those ports.
* Must be able to respond to an ACME DV request with a provided token.

Let's look at the options I've come up with so far.

# Listen On A Different Port

The easiest solution. No muss, no fuss, whatever is on port 80 keeps on doing
its thing while we use port 81 (or something else below 1024) to run the DV
process. Unfortunately this is currently impossible as the ACME spec does not
allow using alternate ports. I'm hopeful the spec [will be amended in the future](https://github.com/letsencrypt/acme-spec/issues/33),
but that doesn't help me right now.

# Shut Down Whatever Is Using Port 80

Again a very simple solution, just `service stop` whatever is using port 80,
run our DV, and then start it back up. I mention it mostly for completeness because, as
mentioned, we have no way to know what the thing on port 80 is and even if we
did I doubt anyone would want their website being randomly shut down for a
minute every few months. This seems to be the expected use case for the
`standalone` mode in the `letsencrypt` client tool.

From here we have to get creative.

# Iptables REDIRECT For DV Request

Linux's iptables has a feature that allows rewriting the destination port on a
packet. This allows things like transparent interception by Squid and other
proxy tools, but we could use it to find the packets containing the DV request
and quietly move them to another port to talk to a service we control. This
would be entirely Linux-specific, but at this point I'm okay with that as
we would need option #1 above to have a cross-platform solution.

The trouble is in only redirecting the DV traffic. The simplest way to do this
would be to use the source IPs that correspond to Let's Encrypt in the iptables
rule, but [Let's Encrypt has veto'd this solution](https://community.letsencrypt.org/t/ip-addresses-le-is-validating-from-to-build-firewall-rule/5410/8).
Another possible option is to use iptables' `string` matching module, but
redirect rules have to run very early in the firewall processing and it seems
to be before the packet contents are available. It is possible that there is a
way to execute on this, but I've not been able to find it. If you know the
right iptables voodoo please let me know.

# Iptables REDIRECT For All Traffic

Failing a more specific rule, we can still use a redirect to rewrite all traffic
coming in on port 80 to go to our service instead, and then proxy everything
except the DV request. This works, but has the downside of putting things behind
a possibly unexpected proxy. The remote IP on the web app request will temporarily
be localhost instead of the true client IP. There are ways to cope with this (
`X-Forwarded-For`, `PROXY` protocol), but an app caught unawares could break in
new and exciting ways. Additionally there might be performance concerns in
sending all traffic through a proxy likely written in Ruby.

Like before, it is possible there is a way to re-inject the packets in to the
kernel preserving the original source IP, but I've not found it. Linux's TPROXY
system is close, but requires some complex network topology to make it work.

# Use Libnetfiler_Queue From Ruby

The [`netfilter_queue` API](http://www.netfilter.org/projects/libnetfilter_queue/doxygen/index.html)
provides a way for a userspace process to insert itself into the firewall process.
This is also Linux-only, and somewhat more bespoke than iptables redirects, but
seems to be supported on all the distros I checked. It works by registering
with the kernel and then processing each packet as it comes in, deciding to
accept, reject, or alter each packet as needed. Now the fun part; Chef's client
omnibus packages include both libffi and the `ffi` Ruby gem, allowing for me
to directly call C APIs without installing a compiler (I take it as a given
that I can't request a compiler). We could potentially have Chef connect as the
active netfilter queue, watch for the DV request packets, and rewrite them to a
new port as needed.

There are, however, some pretty steep downsides. The data you get from the kernel
is a raw TCP packet as a byte array. This would mean parsing both TCP and HTTP
before we can even get to the data we need, not to mention this needs to process
not just the traffic on port 80 but every packet the machine is getting. I am
not normally one to jump on the "dynamic languages are slow" bandwagon but even
I shy away from a performance problem of this magnitude. Additionally this would
require installing the userspace libnetfilter libraries via the OS packaging
tools, which would be generally unpleasant and would likely make supporting
the long tail of weird Linuxes more difficult.

# Use Libnetfilter_Queue From Go

So if Ruby is probably too slow and we don't want to have to install the
userspace library that means we are looking for something that is relatively
fast for processing string-y data, supports static compilation well, and can
easily call C APIs. The only thing I know of that fits all three criteria is
Go. This would mean writing the netfilter code in Go, building a static binary
(or two, 32 vs 64 bit), including it via a `cookbook_file` resource, and just
hoping that the whole house of cards doesn't come tumbling down.

The upside is significant though, this could provide a truly transparent
solution.

# More Options?

These are the possible solutions I've come up with so far, and everything is
either impossible or seems like a terrible idea. I would love to see either
alternate ports or static IPs for the validators as either would allow for a
reasonably elegant solution. Without either, I'm all ears for better options.

# Which To Use?

And now we reach the audience participation section. I would really like to
write this letsencrypt cookbook with the simplicity I mentioned above. Doing
that today requires I pick between one of the aforementioned options (or hope
someone else has a better one). Of all of those only two seem workable:

* Iptables REDIRECT all traffic through a temporary proxy.
* Use libnetfilter_queue from Go and distribute a static binary.

The first has the `REMOTE_IP` issue I mentioned, but is far simpler and seems
less likely to explode hilariously. If I went this route I would have to clearly
document the restriction and offer the ability to configure forwarding headers.
The second could be truly transparent but requires a lot of complex
*::jazzhands::* software.

Which would you rather see if you were a user of this cookbook?

