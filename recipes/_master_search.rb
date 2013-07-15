#
# Cookbook Name:: monitor
# Recipe:: _master_search
#
# Copyright 2013, Sean Porter Consulting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ip_type = node["monitor"]["use_local_ipv4"] ? "local_ipv4" : "public_ipv4"
master_address = node["monitor"]["master_address"]

case
when Chef::Config[:solo]
  master_address ||= "localhost"
when master_address.nil?
  if node["recipes"].include?("monitor::master")
    master_address = "localhost"
  else
    master_node = case
    when node["monitor"]["environment_aware_search"]
      search(:node, "chef_environment:#{node.chef_environment} AND recipes:monitor\\:\\:master").first
    else
      search(:node, "recipes:monitor\\:\\:master").first
    end

    master_address = case
    when master_node.has_key?("cloud")
      master_node["cloud"][ip_type] || master_node["ipaddress"]
    else
      master_node["ipaddress"]
    end
  end
end

node.override["sensu"]["rabbitmq"]["host"] = master_address
node.override["sensu"]["redis"]["host"] = master_address
node.override["sensu"]["api"]["host"] = master_address
