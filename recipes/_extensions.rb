#
# Cookbook Name:: monitor
# Recipe:: _extensions
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

%w[
  client
  server
].each do |service|
  extension_dir = node["monitor"]["#{service}_extension_dir"]

  directory extension_dir do
    recursive true
    owner "root"
    group "sensu"
    mode 0750
  end

  config_path = case node.platform_family
  when "rhel", "fedora"
    "/etc/sysconfig/sensu-#{service}"
  else
    "/etc/default/sensu-#{service}"
  end

  file config_path do
    owner "root"
    group "root"
    mode 0744
    content "EXTENSION_DIR=#{extension_dir}"
    notifies :create, "ruby_block[sensu_service_trigger]", :immediately
  end
end
