#
# Cookbook Name:: monitor
# Recipe:: _worker
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

include_recipe "monitor::_master_search"

include_recipe "sensu::default"

sensu_gem "sensu-plugin" do
  version node["monitor"]["sensu_plugin_version"]
end

handlers = node["monitor"]["default_handlers"] + node["monitor"]["metric_handlers"]
handlers.each do |handler_name|
  next if handler_name == "debug"
  include_recipe "monitor::_#{handler_name}_handler"
end

sensu_handler "default" do
  type "set"
  handlers node["monitor"]["default_handlers"]
end

sensu_handler "metrics" do
  type "set"
  handlers node["monitor"]["metric_handlers"]
end

check_definitions = case
when Chef::Config[:solo]
  data_bag("sensu_checks").map do |item|
    data_bag_item("sensu_checks", item)
  end
when Chef::DataBag.list.has_key?("sensu_checks")
  search(:sensu_checks, "*:*")
else
  Array.new
end

check_definitions.each do |check|
  sensu_check check["id"] do
    type check["type"]
    command check["command"]
    subscribers check["subscribers"]
    interval check["interval"]
    handlers check["handlers"]
    additional check["additional"]
  end
end

include_recipe "sensu::server_service"
