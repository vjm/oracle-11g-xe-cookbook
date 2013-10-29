#
# Cookbook Name:: oracle-11g-xe
# Recipe:: configure
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



execute 'configure-oracle' do
	user 'root'
	command "#{node['oracle-11g-xe'][:oracle_daemon]} configure responseFile=#{node['oracle-11g-xe'][:xe_rsp]} >> #{node['oracle-11g-xe'][:oracle_log_file]}"
	creates "/u01/app/oracle/oradata"
	# action :nothing # only runs if execute['oracle-xe-rpm'] runs properly
	# notifies :create, "link[/etc/profile.d/oracle_env.sh]"
	returns [0,1] # don't care if it's already configured
end

bashrc = "/etc/bashrc"
oracle_bash_profile = "/u01/app/oracle/.bash_profile"
oracle_bashrc = "/u01/app/oracle/.bashrc"

file bashrc do
	owner "root"
	group "root"
	mode "0755"
	action :create_if_missing
end

file oracle_bash_profile do
	owner "oracle"
	group "dba"
	mode "0644"
	action :create_if_missing
end

file oracle_bashrc do
	owner "oracle"
	group "dba"
	mode "0644"
	action :create_if_missing
end

execute "set-oracle-environment" do
	user "root"
	command "echo \"\n. #{node['oracle-11g-xe'][:oracle_env_path]}\" >> #{bashrc}"
	notifies :run, "execute[fill-bash-files]", :immediately
end

execute "fill-bash-files" do
	user "root"
	command "cat /home/vagrant/.bash_profile >> #{oracle_bash_profile}; cat /home/vagrant/.bashrc >> #{oracle_bashrc};"
	action :nothing
end

execute "stop-listener" do
	user 'oracle'
	command ". #{node["oracle-11g-xe"][:oracle_env_path]}; lsnrctl stop"
	# action :nothing # only runs if notified
	notifies :delete, "file[#{node['oracle-11g-xe'][:listener_ora]}]", :immediately
	notifies :delete, "file[#{node['oracle-11g-xe'][:tnsnames_ora]}]", :immediately
	notifies :create, "template[#{node['oracle-11g-xe'][:listener_ora]}]", :immediately
	notifies :create, "template[#{node['oracle-11g-xe'][:tnsnames_ora]}]", :immediately
	notifies :run, "execute[start-listener]", :immediately
end

file node['oracle-11g-xe'][:listener_ora] do
	action :nothing
end

file node['oracle-11g-xe'][:tnsnames_ora] do
	action :nothing
end

execute "start-listener" do
	user 'oracle'
	command ". #{node["oracle-11g-xe"][:oracle_env_path]}; lsnrctl start"
	action :nothing # only runs if notified
end

template node['oracle-11g-xe'][:listener_ora] do
  action :create
  source "listener.ora.erb"
  mode 0755
  owner "oracle"
  group "dba"
  action :nothing # only runs if notified
end

template node['oracle-11g-xe'][:tnsnames_ora] do
  action :create
  source "tnsnames.ora.erb"
  mode 0755
  owner "oracle"
  group "dba"
  action :nothing # only runs if notified
  # notifies :create, "cookbook_file[#{listener_ora}]"
end