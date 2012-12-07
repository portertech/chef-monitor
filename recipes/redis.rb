#
# Cookbook Name:: monitor
# Recipe:: redis
#
# Copyright 2012, Sean Porter Consulting
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

include_recipe "monitor::default"

sensu_gem "redis"

cookbook_file "/etc/sensu/plugins/redis-metrics.rb" do
  source "plugins/redis-metrics.rb"
  mode 0755
end

sensu_check "redis_process" do
  command "check-procs.rb -p redis-server -C 1"
  handlers ["default"]
  standalone true
  interval 30
end

sensu_check "redis_metrics" do
  type "metric"
  command "redis-metrics.rb"
  handlers ["metrics"]
  standalone true
  interval 30
end
