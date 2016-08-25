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
configuring the Vault server hostname, but for now let's just look at the
structural complications.

# Using Node Data For Policy Mapping

Looking at authorization first, Vault already has a powerful ACL and policies
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
chef-vaults `-S` search mode), any compromised node could potentially modify
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
would require update on both the normal node ACL object and a new `node_admin`
ACL object of the same name. This is structurally similar to how some Chef
policy API calls require both `policy` and `policy_group` permissions.

The downside here is mostly that few people know the Erchef codebase well enough
to add this feature, and those that do are very busy. Adding this feature could
take a lot of back and forth and as it's a security-relevant issue, shortcuts
are generally not an option. Overall this seems like the best short-term option
though, even with the development challenges.

## Future Fix: Splitting Up the Node

Looking out towards the future, the even more optimal solution is to split apart
the node data. Currently the server-side node object contains both proscriptive
(what the node wants to be, policy name, run list, environment) and descriptive
(what the node is currently, attribute data from the last run). The node needs
write access to itself in order to update the descriptive data, but there is
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
trusting either and IP or a hostname from some other provisioning layer, and
trusting that an attacker wasn't able to intercept that SSH or WinRM connection.
If either of those assumptions end up false, the bottom falls out of identity
model as an attacker could posses the private key which defines the identity.

Vault has a lot of authentication options and so is more flexible when it comes
to bootstrapping, but the final bit of the process is similar. A token of some
kind (usually a one-time-use token used to access a SecretID) is sent over to
the target machine over SSH or WinRM which is eventually redeemed for a more
durable token. That durable token is then written to disk and is the basis for
that server's identity going forward.

In order to use Chef Server data for mapping Vault policies, we need to link
Chef and Vault identities. The two most obvious ways to do this would be to
base Vault identity on Chef's or vice versa.

## Chef as the Identity Root

Use Chef client keys to generate a Vault token as needed. Short vs long lived,
short is better. Policy mapping happens when requesting a new token, it will
be attached to the policies based on node data from Chef Server.

### Vault Token Service

Little REST service running alongside Vault. Has a high-permission (i.e. can
create tokens for any policy) identity itself as well as Chef API credentials.
Chef recipe code would use existing Chef API authentication protocols to sign
a nonce/timestamp and send it to the Token Service, which would verify the
signature, grab the relevant node data, and then create a new Vault token with
the correct policy. The Chef recipe code would then cache that token in memory
and use it for the rest of the current converge.

### Vault Auth Plugin

All of the above but inside Vault as an auth plugin. Reduces operational
complexity by having one fewer microservice to run, but Vault doesn't support
loading plugins at runtime currently so this would have to done as a custom
compiled binary for now. If this would be accepted upstream it would be more
reasonable a short term mini-fork.

## Vault as the Identity Root

Using vault to issue Chef client keys. Integrated at the level of the Chef
configuration, when a converge starts it would use the server's Vault token
to request a new Chef client key and a short-lived Vault token to use for
secrets access during that converge. As noted above, Vault doesn't support
loading plugins at runtime so this would have to be with the buy-in of Hashicorp
as a feature they would be interested in upstream.
