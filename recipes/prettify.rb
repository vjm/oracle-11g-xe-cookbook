#
# Cookbook Name:: oracle-11g-xe
# Recipe:: prettify
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

bash_aliases = ((Pathname.new(node["oracle-11g-xe"][:temp_dir])) + '/bash-aliases').to_s

bashrc = "/etc/bashrc"
file bashrc do
	owner "root"
	group "root"
	mode "0755"
	action :create_if_missing
end

cookbook_file bash_aliases do
  source "bash-aliases"
  mode 0600
  owner "root"
  group "root"
  action :create_if_missing
  notifies :run, "execute[append-bash-aliases]", :immediately
end

execute "append-bash-aliases" do
	user "root"
	command "cat #{bash_aliases} >> #{bashrc}"
end