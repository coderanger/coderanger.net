---
title: "System Monitoring: A Play in 5 Acts"
---

Act 1: Munin
------------

Munin is dead simple to configure and deploy, and has a very simple, modular
sensor API. It uses a collection agent so it can easily monitor values not
readable over the network (which is a hard requirement for me). Beyond that
it is really just a small wrapper over RRDTool. Its graph UI is painfully
simple and it has only the simplest of alerting systems.

Act 2: Munin and Nagios
-----------------------

Nagios is the gold standard when it comes to FOSS network monitoring. It is
primarily aimed at alerting on failures, so Munin is still needed for
logging time sequence data like performance metrics. This provides more
reliable reporting, but it comes with several downsides. One option is to
simply duplicate any required sensors between Munin and Nagios. Another is to
use the Munin data to trigger alerts in Nagios. This prevents the duplication,
but you are still stuck with Munin's UI for graphing.

Act 3: Nagiosgraph
------------------

There are several addons for Nagios that add time-sequence logging, Nagiosgraph
and PNP being the most popular. These do require special support from the
sensor scripts, but most common plugins will generate the needed output. This
does provide a much nicer interface, but it does mean you lose the simplicity
of Munin.

Act 4: Zabbix
-------------

Zabbix is a young upstart in the monitoring field. It shows a lot of promise
as a potential replacement for Nagios, with much simpler configuration and UI.
The downside is it doesn't seem to have any support for logging performance
data, so it is a non-starter for now.

Act 5: Opsview
--------------

Opsview is built on top of Nagios and Nagiosgraph. It provides some minor UI
enhancements as well as some major performance fixes (which I am unlikely to
ever notice with ~10 machines to monitor). It also provides somewhat
simplified configuration, though the full power of Nagios is available if you
dig in to the system.

Conclusion
----------

Opsview seems to be no worse than vanilla Nagios, and it does provide a
slightly nicer base to build from. Overall this does feel like picking the
lesser of several evils though. The only well-known entry in the Python world
is Zenoss, which has minimal remote monitoring capabilities and seems to be
even more complex and convoluted than Nagios. Munin 2.0 does show some promise
as a future option, but for now Opsview looks like the way to go.
