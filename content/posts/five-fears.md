---
title: Five Things That Should Scare You
date: 2015-10-12
hire_me: Hiring Chef engineers or tool developers? I'm looking for a new team! Check out my <a href="/looking-for-group/">Looking for Group</a> post for details.
---

The world of computers is full of many dangerous nooks and crannies. Hackers,
viruses, and scammers all sit as the boogeymen of the modern age. Some threats
are less well known though, even amongst the keepers of gates. This is my
personal list of the five worst things floating around the chips and waves,
based on notability, danger, and most of all the lack of mitigation strategies.

# BadUSB

USB is pervasive: almost every computer produced in the past decade will have
some form of USB port, most modern portable devices are charged via USB, and
some new laptops are even forgoing dedicated charging ports in favor of [USB-C](https://en.wikipedia.org/wiki/USB_Type-C).
Behind every one of those USB ports is a small controller chip acting handling
the low-level details of the USB protocol and signaling the CPU when data is
decoded and ready (or vice versa). These controller chips started off as
relatively dedicated silicon, but as the USB protocol has become more complex
and general-purpose chips have come down in price, often they are
[generic co-processors](http://www.genesyslogic.com/en/product_view.php?show=21) with small embedded flash memory and their own firmware.
With this change came the possibility to reprogram them remotely, a huge
time saver when building circuit boards.

Unfortunately this also brought with it a new attack surface. Many of these
USB chipsets don't adequately protect their firmware. In some cases they simply
don't disable write access to the firmware, and others have vulnerabilities in their
write restrictions.

This has led to malware that spreads directly from one USB controller to another,
totally outside of the control of the operating system. Each USB controller
infected with a [BadUSB](https://srlabs.de/badusb/)-style virus will attempt to attack the firmware of every
USB port it is connected to. Once the firmware is overwritten, there is
generally no way to even detect it other than to connect a USB debugger and
monitor the traffic. On its own, this could simply be annoying, but when
combined with a dangerous payload this can lead to things like invisible
keyloggers, secret webcam monitors, or launching points for more complex
attacks.

Protecting yourself from BadUSB is a difficult prospect. The first line of
defense is to not use devices vulnerable to firmware attacks, but it can be
difficult to find information on which devices are vulnerable. Avoiding
untrusted USB devices is a good step, but it only takes one misstep for this to
fail. Similarly you can keep power-only USB connectors, sometimes called "USB
condoms", to allow charging with untrusted connections. Overall, as will be a
pattern here today, just hope nothing goes wrong really really hard.

# RowHammer

In 1936 Alan Turing laid out the structure for what is now known as a Turing
Machine. The ensuring 79 years have brought almost unfathomable advances to
computer technology, but deep down in the model is the idea of a tape (RAM)
which programs can read from and write to. An almost unspoken assumption in this
model is that if a memory cell is written to, it will contain the same value
later on when we read from it. RowHammer smashed this assumption.

As RAM storage sizes have skyrocketed with physical chip sizes sink, individual
memory cells have gotten smaller and packed more and more densely. RowHammer
exploits this by using electrical interference from neighboring cells to flip
bits. By issuing hundreds of thousands of writes to nearby memory locations,
every now and then the interference can cause a voltage spike just big enough
to flip a bit. In practical terms, this means a program can change a value in
RAM that it isn't supposed to have write access to. This has led to things
like [local privilege escalation](http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html) and hypervisor attacks on top of existing
remote code execution vulnerabilities. More recently a proof-of-concept
[Rowhammer.js](https://github.com/IAIK/rowhammerjs) has shown that bitflips can be achieved from plain Javascript to
potentially attack browser sandboxing.

Protecting against RowHammer is a difficult proposition. It does require some
level of code execution, so patching local code execution issues and using
browser plugins like NoScript can help, but zero-days will always be a threat.
At a more fundamental level, RowHammer represents a physical problem with how
we build RAM. Error-correcting (ECC) RAM does help by effectively blocking all
single-bit flips and some double-bit flips, but this only makes RowHammer
attacks take longer, not actually prevent them. Some more recent server hardware
allows monitoring the rate of writes which could be used to detect an
in-progress RowHammer attack. New types of RAM are being developed which could
reduce or eliminate this threat, so keep an eye out for announcements from the
memory industry.

# Cloud CPU Side-Channels

Building on top of the fail that is "RAM has currently unfixable physical flaws"
is the fact that most of us now run our servers on huge, multi-tenant clouds.
Side-channel attacks are similar probabilistic or timing based methods, but to
extract data from another virtual machine (or process, but we'll just talk about
virtual machine-level attacks). The specific vectors are numerous and
continually evolving, but generally exploit hardware features created to make
things faster for single-tenant desktops and laptops. Examples include timing
attacks against the L2 or L3 CPU caches, CPU power usage analysis, and attacks
against RAM technologies like the translation look-aside buffer (TLB). By
running code to constantly poke these bits of hardware you can look for patterns
that correspond to known software or data. We can do things like learn what
programs are running on other VMs, what kind of data they are processing, or in
some cases even extract specific data. A recent attack even managed to extract
[private key material across VM boundaries](https://eprint.iacr.org/2015/898.pdf). This can even extend beyond local
attacks, an issue in GPG allowed extracting key material by
analyzing the electromagnetic radiation given off by the CPU.

Unfortunately all of these attacks are things that will have to be fixed by a
mix of hardware improvements and cloud vendor support for those new features.
For now, keep a careful eye on how much sensitive information you put on
multi-tenant systems. Consider applying techniques used to mitigate
remote timing attacks (constant time compares, etc) to truly critical data.

# Pineapple Attacks

Originally developed as part of the [KARMA exploit toolkit](http://theta44.org/karma/),
the [WiFi Pineapple attack platform](https://www.wifipineapple.com/) has carried on the torch onwards. To discuss
the attack itself, we need to talk about how WiFi works. Most WiFi access
points will regularly send out "beacon" packets, containing information about
themselves, including the network name and which frequency it is operating on.
These beacon broadcasts are used to populate the list of what networks are
available, so you can connect to a network without having to type in all the
details manually. The downside is that on some access points, beacons can be
as slow as once every 30 seconds. To speed up reconnection, when your laptop
wakes up it sends out a "probe request" packet for each saved network it knows
about asking that if that access point is nearby, please respond.

The attack is similar to things like [ARP cache poisoning](https://speakerdeck.com/coderanger/how-the-internet-works-with-notes?slide=50): the responder simply
lies and happily replies to any probe request. This tricks the computer in to
joining the attackers access point, believing it to be one of their saved
networks. This usually works with unencrypted networks, as if the attacker doesn't
know the encryption key they would be unable to fake the later parts of the
authentication cycle.

Some newer operating systems like iOS mitigate this by not sending probe requests with
specific network names, rather requesting every access point within range send
a new beacon packet immediately. This prevents direct attacks, but some related
attacks are still possible by observing the beacon packets and creating a race
condition where the victim might be fooled into joining the attacker's network
instead.

For most other OSes (including OS X and most laptop-friendly Linux distros) the
best defense is to never leave open/unencrypted networks in your saved networks
list. You can prune this list after using open networks, though this can still
leave you vulnerable to determined pineapple attackers depending on the specifics
of your OS.

# Shor's Algorithm

Much of modern cryptography is built on the fact that multiplying two very big
numbers is fast, but finding the prime factors for a very big number is slow.
This asymmetry powers the math that allows things like HTTPS and most other
secure communication systems we have today. [Shor's Algorithm](https://en.wikipedia.org/wiki/Shor's_algorithm)
offers a much faster option for finding the prime factors of the huge numbers
used to secure the Internet. Shor's is a quantum algorithm, meaning
it is designed for a quantum computer. It can factor a number in roughly `log N`
time relative to the size of the input number, almost incalculably faster than
the exponential algorithms we have for factorization on traditional silicon.
I mention Shor's specifically as it is the most well known at this point, but
there are is growing body of research looking at quantum factorization in general.

There is, however, a catch; the largest number ever factored via Shor's is 21,
and the [largest via any quantum technique is 56153](http://arxiv.org/pdf/1411.6758v3.pdf).
As of yet no one has managed to build a large enough quantum computer to factor
even marginally non-trivial numbers. This means Shor's (and related quantum
factorization algorithms) are not yet a direct threat, but there is another "but"
to add on here. If someone was nefarious and well-funded enough to record large
amounts of encrypted traffic now, they could conceivably crack it at some point
in the future when more of the engineering issues with building large-scale
quantum computers are solved. I will state for the record that the new NSA
data center in Utah is believed to have a storage capacity in excess of a
trillion terabytes.

Fortunately this is also the easiest thing on this list to defend against.
Modern TLS implementations support an increasing number of cryptographic options
that aren't based on prime numbers. While isn't inconceivable that a quantum
algorithm to solve elliptic curve problems will be developed, it is at least
better than a system that we already know how to break. Keep up with modern
TLS best practices and your biggest fears will have to be whatever encrypted
data was already recorded, sitting somewhere and waiting for the quantum-powered
future to arrive.

## Further Reading

<div style="font-size: 80%;">
* [https://srlabs.de/blog/wp-content/uploads/2014/11/SRLabs-BadUSB-Pacsec-v2.pdf](https://srlabs.de/blog/wp-content/uploads/2014/11/SRLabs-BadUSB-Pacsec-v2.pdf)
* [https://www.cert.gov.uk/wp-content/uploads/2014/10/The-bad-USB-vulnerability1.pdf](https://www.cert.gov.uk/wp-content/uploads/2014/10/The-bad-USB-vulnerability1.pdf)
* [https://blog.trailofbits.com/2015/07/21/hardware-side-channels-in-the-cloud/](https://blog.trailofbits.com/2015/07/21/hardware-side-channels-in-the-cloud/)
* [https://insights.sei.cmu.edu/cert/2015/08/instant-karma-might-still-get-you.html](https://insights.sei.cmu.edu/cert/2015/08/instant-karma-might-still-get-you.html)
* [https://blog.cloudflare.com/ecdsa-the-digital-signature-algorithm-of-a-better-internet/](https://blog.cloudflare.com/ecdsa-the-digital-signature-algorithm-of-a-better-internet/)
* [https://www.youtube.com/watch?v=GZeUntdObCA](https://www.youtube.com/watch?v=GZeUntdObCA)
</div>
