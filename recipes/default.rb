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
# oracle_rpm_script = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'oracle_rpm_install.sh').to_s
oracle_logs_dir = ((Pathname.new(node["oracle-11g-ee"][:temp_dir])) + '/xe_logs').to_s
oracle_log_file = oracle_logs_dir + '/XEsilentinstall.log'
xe_rsp = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'xe.rsp').to_s
# oracle_rpm_path = (File.join(Chef::Config[:file_cache_path], oracle_rpm_name)).to_s
oracle_rpm_path = "#{Chef::Config[:file_cache_path]}/#{oracle_rpm_name}"

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

execute 'configure-ip-tables' do
	user 'root'
	command "echo '-A INPUT -m state --state NEW -m tcp -p tcp --dport #{node['oracle-11g-ee'][:oracle_listener_port]} -j ACCEPT' >> /etc/sysconfig/iptables"
end