---
title: Using Chef with Hashicorp Vault
date: 2016-08-24
published: false
---

# The Goal

To put a tl;dr right up front, the goal of this proposal is to allow for
something like this to work without per-host configuration:

```ruby
file '/etc/myapp/foo.pem' do
  content Vault.logical.read('secret/myapp/foo.pem')
end
```

This means every Chef client in the infrastructure needs to be able to
transparently access the Hashicorp Vault (hereafter just Vault) server.

# The Main Problems

The two main obstacles to this are figuring out what secrets each Chef client
should access to (authorization) and figuring out how to get access credentials
for both Chef Server and Vault (authentication). This proposal doesn't look at
the Chef DSL side, which will require some additional complexity for things like
configuring the Vault server hostname, for now let's just look at the
structural complications.

# Using Node Data For Policy Mapping

Looking at authorization first, Vault already has a powerful ACL and policy
system for controlling access to secrets. The part we need in the middle is to
map each Chef node/client to one or more Vault polices. Fortunately what secrets
a Chef client needs is generally related to what kind of server it is on. We
already have this data in the form of either Chef policy names (if using the
new Policyfile system) or roles/role cookbooks in the node's run list. Using
this data to gate access to secrets feels very natural, has minimal impact on
existing Chef workflows, and allows for flexible ACL targeting. The downside is
that doing so today is grossly insecure.

As things stand today, every Chef client has permissions to update its own node
object. This is how the node attribute data gets saved back up to the Chef
Server at the end of every converge. Because Chef's API operates at the
granularity of whole objects, this also means every client can update their own
policy name or run list. If we used this data for security purposes (e.g.
chef-vault's `-S` search mode), any compromised node could potentially modify
its own run list and thus escalate its privileges in the infrastructure. While
this would require a root-level vulnerability to exploit, those are not unheard
and this is a rather frustrating security hole.

There are a few options to fix this, all revolving around allowing a node to
continue updating its attribute data, but blocking updates to things like the
run list.

## External Fix: Security Proxy

The least intrusive way to fix this issue is to use something outside of Chef
Server. This would be a proxy that sits right in front of Chef Server and
intercepts `PUT /nodes/foo` requests and checks them. The downside is that this
proxy would have to replicate a lot of the logic that already exists inside Chef
Server for decoding requests, checking organization permissions, verifying
request signatures, and applying object ACLs. Some of those steps could be
skipped, drastically simplifying the proxy code, but at the risk of potentially
disclosing some node data to an attacker (i.e. they could spam the proxy with
requests and see which are rejected, and thus deduce the state of the run list
et al). There is also likely to be a higher performance impact as every request
needs to go through two levels of verification. Doing the actual verification
would require getting the current node object from the Chef Server and diffing
against the request content to see if a "protected" field is being changed, and
then checking which client/user initiated the request. That said, even
duplicating features of Chef Server, this  is is likely to be the quickest
turnaround time as it can be built and tested independently.

## Internal Fix: New ACLs

If we want to re-use the existing Chef Server code for things like ACL and
organization checks, the most logical place for this to live is inside Chef
Server itself. The verification logic would look similar to the proxy above,
getting the existing node object from the database and diffing against the new
content. If a "protected" field is being changed, an extra ACL could be checked
(e.g. `nodes_admin`). This would mean having update permissions on the node
object would let you change normal fields, but changing a "protected" field
would require update on both the normal node object and a new `node_admin`
ACL of the same name. This is structurally similar to how some Chef
policy API calls require both `policy` and `policy_group` permissions.

The downside here is mostly that few people know the Erchef code base well enough
to add this feature quickly, and those that do are very busy. Adding this feature could
take a lot of back and forth and as it's a security-relevant issue, shortcuts
are generally not an option. Overall this seems like the best short-term option
though, even with the development challenges.

## Future Fix: Splitting Up the Node

Looking out towards the future, the even more optimal solution is to split apart
the node data. Currently the server-side node object contains both proscriptive
(what the node wants to be, policy name, run list, environment) and descriptive
(what the node is currently, attribute data from the last run). The node needs
update access to itself in order to update the descriptive data, but there is no
reason those two things need to live in a single server-side object. If we split
them apart more fully, it would make having differing ACLs more natural and
efficient. This has been discussed for a long time in the Chef community, but
any movement is probably on hold until we get a chance to revise node attributes
as that would have a big impact on the API design. It would also be relatively
disruptive so we're looking at a multi-year deprecation cycle most likely.
Still, some day this will hopefully be an option.

# Identity Management

Every server needs an identity both to talk to Chef Server and to talk to Vault.
On the Chef side this is accomplished using an RSA public/private key pair. The
pair is generated during `knife bootstrap` (usually) and the public key is
registered with the Chef Server as a new client object. The private key is sent
from the workstation running the bootstrap to the target using either SSH or
WinRM, though usually we can't verify that transport connection so we are
trusting either an IP or hostname from some other provisioning layer, and
trusting that an attacker wasn't able to intercept the SSH or WinRM connection.
If either of those assumptions end up incorrect, the bottom falls out of the identity
model as an attacker could possess the private key which defines the identity.

Vault has a lot of authentication options and so is more flexible when it comes
to bootstrapping, but the final bit of the process is similar. A token of some
kind (usually a one-time-use token used to access a SecretID) is sent over to
the target machine over SSH or WinRM which is eventually redeemed for a more
durable token. That durable token is then written to disk and is the basis for
that server's identity going forward. This shares some of the problems with Chef's
bootstrap model, but you can at least detect when an attack is happening through
response wrapping.

In order to use Chef Server data for mapping Vault policies, we need to link
Chef and Vault identities. The two most obvious ways to do this would be to
base Vault's identity on Chef's or vice versa.

## Chef as the Identity Root

The most straightforward way to do this is to use the Chef identity as the "one
true identity" for the server. If an infrastructure is coming to this from the
side of being an existing Chef user and wanted to deploy Vault, they would
already have the Chef key files in place and probably have some kind of
bootstrap system (e.g. `knife bootstrap`) for generating new identities and
distributing them. What this means in real terms is that we want to use our
Chef client key pair to request a Vault token. The thing answering this request
can verify the request signature just like on any other Chef API request. With
a verified client name in hand, we can use that to look up the node object and
do whatever policy mapping we want to before handing back a Vault token.

We do have a few options for strategies when generating the Vault token. The
simplest would be to do this once during system bootstrap and write the Vault
token next to the Chef key files in `/etc/chef` or similar. The downside of this
is that future changes in the node's run list et al would not result in a new
policy being applied to the existing token. A better approach would be to
request a new token at the start of each Chef converge and store it in memory.
Each time we request a new token, the thing generating them will see the updated
node data and issue the token's policy accordingly.

The next hard part is to figure out what actually does the token creation.

### Vault Token Service

As before, the simplest solution is to build a new tiny REST service that runs
alongside Vault. This would get an API request from the Chef client, verify it
in a similar fashion to Chef Server (though we don't need ACL checks so this
would involve less feature duplication than the proxy service discussed before),
do the policy mapping, and then issue a new Vault token. There are already a few
projects out there that do similar things, but none with any significant
community backing at this time.

The downside here is that its another service to operate and manage, but in the
grand scheme of things that doesn't seem so bad. This new service would need to
be handled carefully as it would have to be authorized to create tokens for any
Vault policy that a node can request.

### Vault Auth Plugin

As mentioned, Vault does already support a modular plugin-based authentication
system. The same logic mentioned above could be run directly as a Vault plugin.
This would remove the downside of having another little service to secure and
whatnot. Unfortunately Vault plugins currently have to be compiled in to the
executable directly. Support for loading plugins at runtime is planned, but not
in the near future that I'm aware of. This would mean building our own Vault
binaries for at least a while. If Hashicorp is interested in accepting the
feature upstream we would eventually merge them back together, but until then
we would basically be operating a friendly fork with all the work that implies.

### Built-In To Chef Server

Similarly to building the token issuer in to Vault, we could do the same on the
other side and build it in to Chef Server. This makes me more nervous though,
while the token issuer requires fairly broad permissions on the Vault side, it
needs very few Chef permissions. Putting things in the Chef Server means that
now the whole Chef Server is effectively allowed to create any Vault token for
a node policy. This is a much larger threat surface and sets off my security
engineer mental alarms. There is also the problem that Chef Server has no
plugin structure so this would be a one-off for Vault which feels weird.

## Vault as the Identity Root

Another option is to use the Vault identity as the root of the system. This
would mean changing our bootstrapping tools, but Vault does offer more secure
bootstrap options such as response wrapping and short-lived tokens. In this
model we would create a long-lived token during machine bootstrap that has no
access policies attached to it, just some metadata associating it with a given
Chef client/node name. On every converge we would use this token to first attach
a new Chef client key and then generate a token for the converge as with the
previous examples. This provides some compelling advantages around continuous
re-keying of Chef clients and more secure bootstrap, but might be a bridge too
far for now. It would require a "Chef Key" secrets plugin for Vault with all the
same issues as before about how Vault plugins require effectively forking the
project for a short time at least. This does seem like it might be more
interesting to the Hashicorp team to accept upstream though. Overall a cool
idea but maybe not something to move forward with until Chef and Hashicorp are
both at least somewhat on-board.
