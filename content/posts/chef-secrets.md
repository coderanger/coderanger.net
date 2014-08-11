---
title: Secrets Management and Chef
date: 2014-08-08
published: false
---

Everyone has secrets. Database passwords, API credentials, recovery questions.
These secrets need to be stored somewhere, and then made available to servers
that require them.

# Requirements

When working with secrets we have a few needs above and beyond that of "normal"
configuration data. As with any security-relevant system, the overarching rule
must be the **Principle of Least Privilege**. This means that if a person or
server doesn't require a specific secret, it should not have access to it. We
also generally want some level of access logging to analyze any future problems.
We are also sometimes willing to give up some ground, usually in the form of
version control. Accessing the old value of a password is only needed in
*"oops"* situations, so it isn't as much of a hard requirement for the storage
system.

## Online vs. offline

The first decision to make is if you are looking for **online** (also called
hot) storage or **offline** (also called cold). Online system are used for data
that is needed by servers non-interactively. This is the bulk of secrets, things
like database passwords are needed every time you spin up a new webapp server,
so they need to be retrieved without specific human intervention.

Offline systems are for secrets you don't access often, but do need to store
somewhere for future reference. For example, the master password on an AWS
account should never be needed during day-to-day operations, but you do need
to keep it written down somewhere safe. Offline systems are generally more
secure in an absolute sense, but require human interaction to access data,
sometimes from more than one person.

# Data bags

I covered some of these issues in [my article on data bags](/data-bags/).
Just in the context of secrets, data bags don't really offer great support for
either of our required features. Least Privilege can be accomplished but only
with Enterprise Chef's ACL system, and that is a difficult beast to manage to
say the least. Access logs do exist, but there is nothing to easily
search/manage them. If you use Hosted Chef, the access logs are not directly
accessible at all.

Overall I recommend not using data bags for secrets storage.

# Encrypted data bags

Encrypted data bags use a shared secret and symmetric encryption of the data
bag values. The current version (v2) uses AES-256-CBC with an additional
SHA256 HMAC. The next version (v3) will use AES-256-GCM.

This offer. a bit of a trade, you can achieve Least Privilege
by ensuring that only those that are granted access will have the decryption
key for a particular secret. The downside of this is now you need to manage
and distribute the decryption keys. While this isn't impossible, the keys
are secrets themselves so this is a bit of a recursive problem. On the positive
side, because the data is encrypted at rest it can be checked in to version
control.

Additionally the primary APIs for working with encrypted data bags only allow
one decryption key per server, which usually results in an all-or-nothing
approach and thus violating Least Privilege. Because encrypted data bags use the
same APIs for access, the same issues with audit logging carry over.

The same general issues apply to
[Ansible's Vault](http://docs.ansible.com/playbooks_vault.html) system.

# chef-vault

[Chef-vault](https://github.com/Nordstrom/chef-vault) builds on encrypted
data bags. Rather than a single shared decryption key, chef-vault creates a
separate copy of the data bag item for each node that is granted access, using
the existing RSA public/private key pair normally used for Chef API
authentication. This means you no longer have to worry about distributing the
decryption keys, but it also moves chef-vault into the gray area between
online and offline storage systems.

Once a server is granted access to a secret, it can continue to access it in
an online manner. However granting or revoking new servers requires human
interaction. This means chef-vault is incompatible with auto-scaling or
self-healing systems. It also inherits the same issues with audit logging as
all other data-bag driven approaches.

If you are okay with the limitations on auto-scaling, chef-vault is a solid
option for storing secrets. Make sure to check out the
[accompanying cookbook](https://github.com/opscode-cookbooks/chef-vault) for
some handy DSL extensions.

# Citadel

The [citadel cookbook](https://github.com/poise/citadel) uses a different
approach. Rather than control access using encryption, it uses a **Trusted Third
Party** to mediate access, specifically AWS IAM. It makes use of the IAM Role
feature of EC2 to provide AWS API credentials to the server. Combined with a
private S3 bucket and IAM access policies bound to a role and you can very
tightly control access to secrets. Access logs and versioning are both available
through S3, as is at-rest encryption though this is most likely a red herring
for security.

The big downside of this is it requires you to be entirely AWS-based. It also
comes with a fair amount of complexity on the IAM configuration side, though
this can be somewhat handled through tools like CloudFormation. If you are
already committed to using AWS, it is my current recommendation for secrets
storage.

# Trousseau

[Trousseau](https://github.com/oleiade/trousseau) has a lot of similarities to
chef-vault. It follows the same pattern of encrypting the secrets separately
for each server that will have access to them, but it uses GPG instead of
Chef's encrypted data bag system. This makes it easier to interface with
non-Chef tools, but it doesn't have the same slick DSL extensions for use
within Chef. It also requires an external synchronization server of some kind,
currently it supports S3 and SCP as mechanisms to get the encrypted data to
the server before Trousseau can process it. Due to the complexities of the
synchronization, I would consider Trousseau to mostly be an offline storage
system.

I don't actually know of anyone using Trousseau with Chef, so this is mentioned
mostly for completeness.

# Barbican

[Barbican](https://github.com/openstack/barbican) is a young project being
developed by Rackspace for OpenStack. Its goal is to handle infrastructure-level
secrets storage for OpenStack, such as Cinder encryption keys. I don't think it
is yet at a point where it could be used smoothly for secrets storage with Chef,
but I am hopeful for the future. It could eventually allow something like how
Citadel works, but against a local Barbican server instead of AWS.

# Red October

[Red October](https://github.com/cloudflare/redoctober) is an N-of-M storage
system developed by CloudFlare. It is primarily aimed at offline storage, but
does provide a remote API for online use. It's defining feature is the N-of-M
encryption, meaning that a given secret can be encrypted so that any N out of
the total M people can access it. Let's say you have 5 engineers, you could
set some secrets to be 1-of-5 so they are accessible by anyway, while more
important secrets could be 3-or-5 to ensure a majority of the team authorizes
the access.

Unfortunately tooling around it is incredibly minimal, and it offers little
logging. If you are looking for a solid offline storage tool for
business-critical secrets, definitely give Red October a look.

# ZooKeeper, etcd, consul

Some might be tempted to store their secrets alongside their other run-time
configuration data in ZooKeeper, etcd, or consul. ZooKeeper does have an ACL
system to restrict access, but I've not seen many cases of it being used well
due to the high level of complexity. etcd and consul both lack authentication
and authorization controls, but they are being worked on.

# tl;dr

If you are 100% on AWS, use [Citadel](https://github.com/poise/citadel).

If you will never use any kind of auto-scaling, use
[Chef-vault](https://github.com/Nordstrom/chef-vault).

If you need to store rarely used but high-value secrets, use
[Red October](https://github.com/cloudflare/redoctober).

If none of these apply, you are likely between a rock and a hard place.

---

Looking for help getting the most out of Chef? Check out my [training](/training/) and
[consulting](/consulting/) services.
