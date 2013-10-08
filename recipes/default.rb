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

# http://docs.oracle.com/cd/E17781_01/install.112/e18802/toc.htm#BABCCGCF
# https://gist.github.com/ricardovf/1005206

extract_script = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'extract-zipfiles.sh').to_s
oracle_rpm_script = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'oracle_rpm_install.sh').to_s
xe_rsp = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'xe.rsp').to_s
oracle_rpm_path = (Pathname.new(node["oracle-11g-ee"][:temp_dir]) + 'Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm').to_s

#make sure it's an array. http://www.ruby-doc.org/core-1.9.3/Kernel.html#method-i-Array
zips_to_extract = Array(node["oracle-11g-ee"][:oracle_zipfile]) 

# Install prereq packages
node["oracle-11g-ee"][:pack_list].each do |pkg|
	package pkg
end

# Create temp_dir for oracle ops
directory node["oracle-11g-ee"][:temp_dir] do
	recursive true
	owner 'root'
	group 'root'
	mode '0644'
	action :create
end

# Unzip the oracle zipfile
template extract_script do
	source 'extract-zipfiles.sh.erb'
	owner 'root'
	group 'root'
	mode '0755'
	variables({
		:extract_to => node["oracle-11g-ee"][:temp_dir],
		:zips_to_extract => zips_to_extract
		})
	action :create_if_missing
	notifies :run, "bash[extract-zipfiles]"
end

# Run the extract script - only runs if notified with :run by extract_script template indicating successful unzip
bash 'extract-zipfiles' do
	code extract_script
	user 'root'
	action :nothing
end

# #{xe_rsp} is where this file will be copied to from the 'source'.
template xe_rsp do 
	source 'xe.rsp.erb'
	owner 'root'
	group 'root'
	mode '0444'
	variables({
		:oracle_http_port => node["oracle-11g-ee"][:oracle_http_port],
		:oracle_listener_port => node["oracle-11g-ee"][:oracle_listener_port],
		:oracle_password => node["oracle-11g-ee"][:oracle_password],
		:oracle_confirm_password => node["oracle-11g-ee"][:oracle_password],
		:oracle_dbenable => node["oracle-11g-ee"][:oracle_dbenable]
		})
	action :create_if_missing
end

template oracle_rpm_script do 
	source 'oracle_rpm_install.sh.erb'
	owner 'root'
	group 'root'
	mode '0755'
	variables({
		:oracle_rpm_path => oracle_rpm_path,
		:xe_path => xe_rsp
		})
	action :create_if_missing
	notifies :run, "bash[oracle-rpm-install]"
end

# Run the install script - only runs if notified with :run by oracle_rpm_script template
bash 'oracle-rpm-install' do
	code oracle_rpm_script
	user 'root'
	action :nothing
	notifies :run, "bash[oracle_env]"
end

bash 'oracle_env' do
	code node["oracle-11g-ee"][:oracle_env_path]
	user 'root'
	action :nothing
	notifies :run, "bash[append-to-bashrc]"
end

bash "append-to-bashrc" do
    user "root"
    cwd node["oracle-11g-ee"][:temp_dir]
    code <<-EOT
       echo ". #{node['oracle-11g-ee'][:oracle_env_path]}" >> /root/.bashrc
    EOT
    action :nothing
end