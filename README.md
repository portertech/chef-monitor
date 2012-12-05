Description
===========

Monitor is a cookbook for monitoring services, using Sensu, a
monitoring framework. The default recipe installs & configures the
Sensu client (monitoring agent), as well as common service check
dependencies. The master recipe installs & configures the Sensu server
(event handler) & its dependencies. The remaining recipes are intended
to put monitoring checks in place in order to monitor specific
services.

Learn more about Sensu [Here](https://github.com/sensu/sensu/wiki).

Requirements
============

The [Sensu cookbook](http://community.opscode.com/cookbooks/sensu).

Attributes
==========

`node["monitor"]["sensu_plugin_version"]` - Sensu Plugin library
version.

`node["monitor"]["default_handlers"]` - Default event handlers.

`node["monitor"]["metric_handlers"]` - Metric event handlers.

`node["monitor"]["use_private_ipv4"] - Defaults to false.  If true, use local_ipv4 when available instead of public_ipv4.

Usage
=====

Example: To monitor the Redis service running on a Chef node, include
"recipe[monitor::redis]" in its run list.
