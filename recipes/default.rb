#
# Cookbook Name:: oracle-11g-ee
# Recipe:: default
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

# https://gist.github.com/ricardovf/1005206

# extract_script = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'extract-zipfiles.sh').to_s

oracle_rpm_name = 'oracle-xe-11.2.0-1.0.x86_64.rpm'
oracle_logs_dir = ((Pathname.new(node["oracle-11g-ee"][:temp_dir])) + '/xe_logs').to_s
oracle_log_file = oracle_logs_dir + '/XEsilentinstall.log'
xe_rsp = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'xe.rsp').to_s
allow_remote_oracle_access = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'allow-remote-oracle-access.sql').to_s
oracle_rpm_path = "#{Chef::Config[:file_cache_path]}/#{oracle_rpm_name}"
iptables = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'iptables_setup.sh').to_s
listener_ora = "/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora"
tnsnames_ora = "/u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora"

#make sure it's an array. http://www.ruby-doc.org/core-1.9.3/Kernel.html#method-i-Array
# zips_to_extract = Array(node["oracle-11g-ee"][:oracle_zipfile]) 

# Install prereq packages
node["oracle-11g-ee"][:pack_list].each do |pkg|
	package pkg
end

# remote_file oracle_rpm_path do
# 	source node['oracle-11g-ee'][:rpm_url]
# 	owner 'root'
# 	group 'root'
# 	mode '0644'
# 	action :create
# 	notifies :create, "directory[#{node["oracle-11g-ee"][:temp_dir]}]"
# end

execute 'download-oracle-xe-rpm' do
	cwd Chef::Config[:file_cache_path]
	user 'root'
	command "wget --output-document=#{oracle_rpm_name} #{node['oracle-11g-ee'][:rpm_url]}"
	creates oracle_rpm_path
	# notifies :create, "directory[#{node["oracle-11g-ee"][:temp_dir]}]"
	action :run
end

# Create temp_dir for oracle ops
directory node["oracle-11g-ee"][:temp_dir] do
	recursive true
	owner 'root'
	group 'root'
	mode '0644'
	# action :nothing
	# action :create
	notifies :create, "template[#{xe_rsp}]"
end

# #{xe_rsp} is where this file will be copied to from the 'source'.
template xe_rsp do 
	source 'xe.rsp.erb'
	owner 'root'
	group 'root'
	mode '0444'
	notifies :create, "directory[#{oracle_logs_dir}]"
	action :nothing
end

# Create temp_dir for oracle logs
directory oracle_logs_dir do
	recursive true
	owner 'root'
	group 'root'
	mode '0644'
	action :nothing
	notifies :run, "execute[oracle-xe-rpm]"
end

# we use this instead of package because we want to log our output to this file.
execute 'oracle-xe-rpm' do
	user 'root'
	command "rpm -ivh #{oracle_rpm_path} > #{oracle_log_file}"
	action :nothing
	notifies :run, "execute[configure-oracle]"
end

# package 'oracle-xe' do
# 	source oracle_rpm_path
# 	action :install
# end

execute 'configure-oracle' do
	user 'root'
	command "/etc/init.d/oracle-xe configure responseFile=#{xe_rsp} >> #{oracle_log_file}"
	creates "/u01/app/oracle/oradata"
	action :nothing # only runs if execute['oracle-xe-rpm'] runs properly
	notifies :create, "link[/etc/profile.d/oracle_env.sh]"
	returns [0,1] # don't care if it's already configured
end

link "/etc/profile.d/oracle_env.sh" do
	user 'root'
	to node["oracle-11g-ee"][:oracle_env_path]
	action :nothing
end

# add to oracle_env.sh:
# export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
# export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
# export SQLPATH=$ORACLE_HOME/sqlplus/admin

cookbook_file allow_remote_oracle_access do
  source "allow-remote-oracle-access.sql"
  mode 0600
  owner "root"
  group "root"
  notifies :run, "execute[allow-remote-oracle-access]"
end

execute 'allow-remote-oracle-access' do
	user 'root'
	command "sqlplus system/#{node['oracle-11g-ee'][:oracle_password]} < #{allow_remote_oracle_access}"
	action :nothing # only runs if notified
end

template iptables do 
	source 'iptables_setup.sh.erb'
	owner 'root'
	group 'root'
	mode '0700'
	notifies :run, "execute[iptables-setup]"
	# action :nothing
end

bash 'iptables-setup' do
	user 'root'
	code iptables
	action :nothing # only runs if notified
end

cookbook_file listener_ora do
  action :create
  source "listener.ora"
  mode 0755
  owner "oracle"
  group "dba"
  # notifies :create, "cookbook_file[#{listener_ora}]"
end

cookbook_file tnsnames_ora do
  action :create
  source "tnsnames.ora"
  mode 0755
  owner "oracle"
  group "dba"
  # notifies :create, "cookbook_file[#{listener_ora}]"
end

# cookbook_file "create-#{listener_ora}" do
#   source "listener.ora"
#   mode 0755
#   owner "oracle"
#   group "dba"
#   notifies :run, "execute[allow-remote-oracle-access]"
# end



# try changing the host in the listener.ora and tsnnames.ora to be 192.168.33.10!!!!!!!!!!!!!!!!!!!
# if you can telnet 192.168.33.10 1521 then youre on your way.

# http://stackoverflow.com/questions/5661610/tns-12505-tnslistener-does-not-currently-know-of-sid-given-in-connect-descript/10840177#10840177
# listener.ora Network Configuration File:


# http://www.centos.org/docs/4/4.5/Security_Guide/s1-firewall-ipt-basic.html
# http://stackoverflow.com/questions/9029297/how-to-know-if-a-port-is-open-or-not-in-linux-system
# http://stackoverflow.com/questions/9609130/quick-way-to-find-if-a-port-is-open-on-linux
# /etc/init.d/iptables stop
# chkconfig iptables off