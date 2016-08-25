---
title: Using Chef with Hashicorp Vault
date: 2016-08-24
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

#### Policy mapping, Secure Introduction/identity root. Structure issues only, this
doesn't cover Chef DSL additions or similar, which would be done in parallel.

The two main obstacles to this are figuring out what secrets each Chef client
should access to (authorization) and figuring out how to get access credentials
for both Chef Server and Vault (authentication). This proposal doesn't look at
the Chef DSL side, which will require some additional complexity for things like
configuring the Vault server hostname, but for now let's just look at the
structural complications.

# Using Node Data For Policy Mapping

Describe the problem, self-mutable node data. Using node data (policy name,
roles, etc) is very attractive as it means only defining what a node is in one
place.

## External Fix: Security Proxy

Proxy service in front of Chef Server, performance impact is higher but quicker
turn around. Might have to do signature and ACL checks or risk leaking information
about node data which removes much of the simplicity.

## Internal Fix: New ACLs

Describe node_admin ACL stuffs, all node save operations would have to get the
current object from the DB and diff "protected" fields, if they differ, check
both the node object ACLs and a new node_admin object of the same name. Similar
to policy vs. policy_group already in the code.

## Future Fix: Splitting Up the Node

Optimal solution for the future is to split apart the node data. Currently the
server-side node object contains both proscriptive (what the node wants to
be, policy name, run list, environment) and descriptive (what the node is
currently, attribute data from the last run). The node needs write access to
itself in order to update the descriptive data, but there is reason those two
things need to live in a single server-side object. If we split them apart more
fully, it would make having differing ACLs more natural and efficient.

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
