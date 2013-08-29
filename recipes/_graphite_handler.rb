#
# Cookbook Name:: monitor
# Recipe:: _graphite_handler
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
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

graphite_address = node["monitor"]["graphite_address"]
graphite_port = node["monitor"]["graphite_port"]

ip_type = node["monitor"]["use_local_ipv4"] ? "local_ipv4" : "public_ipv4"

case
when Chef::Config[:solo]
  graphite_address ||= "localhost"
  graphite_port ||= 2003
when graphite_address.nil?
  graphite_node = case
  when node["monitor"]["environment_aware_search"]
    search(:node, "chef_environment:#{node.chef_environment} AND recipes:graphite").first
  else
    search(:node, "recipes:graphite").first
  end

  graphite_address = case
  when graphite_node.has_key?("cloud")
    graphite_node["cloud"][ip_type] || graphite_node["ipaddress"]
  else
    graphite_node["ipaddress"]
  end

  graphite_port = graphite_node["graphite"]["carbon"]["line_receiver_port"]
end

sensu_handler "graphite" do
  type "tcp"
  socket(
    :host => graphite_address,
    :port => graphite_port
  )
  mutator "only_check_output"
end

sensu_handler "graphite_amqp" do
  type "amqp"
  exchange(
    :type => "topic",
    :name => "graphite",
    :durable => true
  )
  mutator "only_check_output"
end
