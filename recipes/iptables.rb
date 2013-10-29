#
# Cookbook Name:: oracle-11g-xe
# Recipe:: iptables
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

template node['oracle-11g-xe'][:iptables] do 
	source 'iptables_setup.sh.erb'
	owner 'root'
	group 'root'
	mode '0700'
	notifies :run, "bash[iptables-setup]"
	action :create
end

bash 'iptables-setup' do
	user 'root'
	code node['oracle-11g-xe'][:iptables]
	action :nothing # only runs if notified
	notifies :restart, "service[iptables]"
end

service 'iptables' do
	supports :restart => true
	action :nothing
end