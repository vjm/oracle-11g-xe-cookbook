#
# Cookbook Name:: oracle-11g-ee
# Recipe:: default
#
# Author:: Mike Ensor (<mike.ensor@acquitygroup.com>)
# Author:: Vince Montalbano (<vince.montalbano@acquitygroup.com>)
# 
# Copyright 2013, Acquity Group
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

ruby_block 'get-hostname' do
  block do
    node.automatic['oracle-11g-ee'][:hostname] = `hostname`
  end
  action :run
end

ruby_block 'get-host-only-ip-address' do
  block do
    node.automatic['oracle-11g-ee'][:host_only_ip] = `ifconfig #{node['oracle-11g-ee'][:host_only_interface]} | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
  end
  action :run
end

node.normal['oracle-11g-ee'][:iptables] = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'iptables_setup.sh').to_s

node.normal['oracle-11g-ee'][:xe_rsp] = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'xe.rsp').to_s

node.normal['oracle-11g-ee'][:oracle_logs_dir] = ((Pathname.new(node["oracle-11g-ee"][:temp_dir])) + '/xe_logs').to_s
node.normal['oracle-11g-ee'][:oracle_log_file] = node['oracle-11g-ee'][:oracle_logs_dir] + '/XEsilentinstall.log'

node.normal['oracle-11g-ee'][:oracle_rpm_path] = "#{Chef::Config[:file_cache_path]}/#{node['oracle-11g-ee'][:oracle_rpm_name]}"


include_recipe "oracle-11g-ee::install"
include_recipe "oracle-11g-ee::configure"
include_recipe "oracle-11g-ee::remote_access"