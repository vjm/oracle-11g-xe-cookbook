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

# link "/etc/rc.d/rc3.d/S99oracle" do
# 	user 'root'
# 	to node["oracle-11g-xe"][:oracle_env_path]
# 	# action :nothing
# 	notifies :delete, "template[#{node['oracle-11g-xe'][:listener_ora]}]", :immediately
# 	notifies :delete, "template[#{node['oracle-11g-xe'][:tnsnames_ora]}]", :immediately
# 	notifies :create, "template[#{node['oracle-11g-xe'][:listener_ora]}]", :immediately
# 	notifies :create, "template[#{node['oracle-11g-xe'][:tnsnames_ora]}]", :immediately
# 	# notifies :run, "execute[start-listener]" #seems like it's already started now
# end

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

execute "start-listener" do
	user 'oracle'
	command ". #{node["oracle-11g-xe"][:oracle_env_path]}; lsnrctl start"
	action :nothing # only runs if notified
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