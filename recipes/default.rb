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

default_temp_dir = "oracle_tmp"
temp_dir = node["oracle-11g-ee"][:temp_dir] || default_temp_dir

extract_script = (Pathname.new(temp_dir) + 'extract-source.sh').to_s
install_script = (Pathname.new(temp_dir) + 'install-mono.sh').to_s

default_pack_list = ["libaio", "bc", "flex"]
pack_list = node["oracle-11g-ee"][:pack_list] || default_pack_list

# Install prereq packages
pack_list.each do |pkg|
  package pkg
end

# Create temp_dir for oracle ops
directory temp_dir do
  recursive true
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# Unzip the oracle zipfile




# unzip -q oracle-xe-11.2.0-1.0.x86_64.rpm.zip
# cd Disk1
# prepare xe.rsp

# ORACLE_LISTENER_PORT: A valid listener numeric port value, so that you can connect to Oracle Database XE
# ORACLE_HTTP_PORT: A valid HTTP port numeric value for Oracle Application Express
# ORACLE_PASSWORD: A password value for the SYS and SYSTEM administrative user accounts
# ORACLE_CONFIRM_PASSWORD: The SYS and SYSTEM password value again, to confirm it
# ORACLE_DBENABLE: Yes (y) or no (n), to specify whether you want to start Oracle Database XE automatically when the computer starts

#!/bin/bash
# rpm -ivh  /downloads/oracle-xe-11.2.0-1.0.x86_64 > /xe_logs/XEsilentinstall.log
# /etc/init.d/oracle-xe configure responseFIle=<location of xe.rsp> >> /xe_logs/XEsilentinstall.log

# run
# /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh

# You may also want edit your login or profile files so that these environment variables are set properly each time you log in or open a new shell.
# For Bourne, Bash, or Korn shell, enter the following line into the .bash_profile (to log in) or .bashrc file (to open a new shell):
# . /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh