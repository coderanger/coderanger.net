---
title: "Ops Glossary: Containers"
date: 2014-08-20
hire_me: Looking for help with your infrastructure? Check out my <a href="/training/">training</a> and <a href="/consulting/">consulting</a> services.
---

Server operations involves a lot of jargon, and there is a lot of variance
between organizations. I won't claim these terms are universal, but I've
found them fairly general and enough to get your meaning across between
sub-dialects. Some tools span multiple classifications, and some focus on only
one.

# Artifact

In general an artifact is the result of some kind of build process. In context,
it usually refers to some kind of disk image that will be used to spawn either
a service or a virtual machine. As the word is somewhat long, I sometimes use
the term "slug" to refer to the same thing.

### Examples:

<table class="examples">
  <tr>
    <td>Amazon AMI</td>
    <td>Docker image</td>
  </tr>
  <tr>
    <td>Omnibus package</td>
    <td>Java JAR</td>
  </tr>
  <tr>
    <td>Python Wheel</td>
    <td>Tarball</td>
  </tr>
</table>


# Artifact Builder

The artifact builder (or slug builder) is the tool or service that creates an
artifact. This sometimes just means assembling files in to a disk image, or
downloading and compiling software. In either case, it may include other
artifacts.

#### Examples:

<table class="examples">
  <tr>
    <td>Packer</td>
    <td>docker build</td>
  </tr>
  <tr>
    <td>Omnibus</td>
    <td>Nix</td>
  </tr>
  <tr>
    <td>Heroku buildpacks</td>
    <td>Maven</td>
  </tr>
</table>


# Artifact Storage

Once you have a built artifact, you need to store it somewhere. The simplest
form is a single web server and local files, but something with an API allows
much more flexibility with access. In some cases this involves repository
formats like apt and yum.

#### Examples:

<table class="examples">
  <tr>
    <td>Nexus</td>
    <td>Artifactory</td>
  </tr>
  <tr>
    <td>S3 (AMIs or apt/yum)</td>
    <td>DevPI</td>
  </tr>
  <tr>
    <td>Docker Registry</td>
    <td>Glance</td>
  </tr>
</table>


# Container

This one will probably be a little more controversial. I consider a container
system to be anything capable of running an artifact. This includes things
commonly thought of as "heavier" virtual machines, as well as simply running
a process. Most container systems are only compatible with a few types of
artifacts so they are generally chosen together, Amazon EC2 can only run AMIs
while a .deb package can be run either directly or inside Docker, et al.

#### Examples

<table class="examples">
  <tr>
    <td>Xen</td>
    <td>KVM</td>
  </tr>
  <tr>
    <td>Docker</td>
    <td>Mesos</td>
  </tr>
  <tr>
    <td>exec()</td>
    <td>Tomcat</td>
  </tr>
</table>


# Isolation

Security isolation between containers helps to allow multi-tenancy and improve
security in single-tenant systems. Isolation systems limit the operations a
running container can take and how they can affect the outside world.

#### Examples

<table class="examples">
  <tr>
    <td>Xen</td>
    <td>KVM</td>
  </tr>
  <tr>
    <td>LXC</td>
    <td>Libcontainer</td>
  </tr>
  <tr>
    <td>Chroot</td>
    <td>ZeroVM</td>
  </tr>
  <tr>
    <td>Zone</td>
    <td>Jail</td>
  </tr>
</table>


# Service Management

Service management starts containers and keeps them running. In some cases, like
AWS EC2, this is just built-in to the platform. Other container systems require
an external tool. Service management tools also often hook in to log management,
monitoring, and alerting.

#### Examples

<table class="examples">
  <tr>
    <td>Systemd</td>
    <td>AWS Auto-Scaling Group</td>
  </tr>
  <tr>
    <td>Supervisord</td>
    <td>Runit</td>
  </tr>
  <tr>
    <td>Aurora</td>
    <td>Fleet</td>
  </tr>
</table>


# Virtualization

This term is now uselessly vague. In days past it referred to systems that
used explicit virtual hardware, but this is almost never done anymore. It can
now rest in peace next to "cloud" and "web 2.0".

