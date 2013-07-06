#
# Cookbook Name:: monitor
# Recipe:: haproxy
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

include_recipe "monitor::_haproxy"

sensu_check "haproxy_services" do
  command "sudo check-haproxy.rb -s :::haproxy_services::: -w :::haproxy_warning|75::: -c :::haproxy_critical|50:::"
  handlers ["default"]
  standalone true
  interval 30
end
