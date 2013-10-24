#
# Cookbook Name:: oracle-11g-ee
# Recipe:: remote_access
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

allow_remote_oracle_access = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'allow-remote-oracle-access.sql').to_s

cookbook_file allow_remote_oracle_access do
  source "allow-remote-oracle-access.sql"
  mode 0600
  owner "root"
  group "root"
  # action :nothing
  action :create_if_missing
  # creates allow_remote_oracle_access
  # notifies :run, "execute[allow-remote-oracle-access]"
end

execute 'allow-remote-oracle-access' do
	user 'root'
	command ". /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh; sqlplus system/#{node['oracle-11g-ee'][:oracle_password]} < #{allow_remote_oracle_access}"
	# action :nothing # only runs if notified
	only_if { File.exists?(allow_remote_oracle_access) }
end