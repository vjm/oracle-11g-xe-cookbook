node.default["oracle-11g-xe"][:temp_dir] = "/oracle_tmp"
node.default["oracle-11g-xe"][:pack_list] = ["libaio", "bc", "flex", "zip", "unzip", "wget"]

node.default["oracle-11g-xe"][:rpm_url] = nil

node.default["oracle-11g-xe"][:oracle_http_port] = 8080
node.default["oracle-11g-xe"][:oracle_listener_port] = 1521
node.default["oracle-11g-xe"][:oracle_password] = "vagrant"
node.default["oracle-11g-xe"][:oracle_dbenable] = true

node.default["oracle-11g-xe"][:oracle_env_path] = "/u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh"
node.default['oracle-11g-xe'][:oracle_daemon] = "/etc/init.d/oracle-xe"

node.default['oracle-11g-xe'][:listener_ora] = "/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora"
node.default['oracle-11g-xe'][:tnsnames_ora] = "/u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora"

node.default['oracle-11g-xe'][:host_only_interface] = "eth1"

node.default['oracle-11g-xe'][:oracle_rpm_name] = 'oracle-xe-11.2.0-1.0.x86_64.rpm'


node.normal['oracle-11g-xe'][:iptables] = (Pathname.new(node["oracle-11g-xe"][:temp_dir]) + 'iptables_setup.sh').to_s

node.normal['oracle-11g-xe'][:xe_rsp] = (Pathname.new(node["oracle-11g-xe"][:temp_dir]) + 'xe.rsp').to_s

node.normal['oracle-11g-xe'][:oracle_logs_dir] = ((Pathname.new(node["oracle-11g-xe"][:temp_dir])) + '/xe_logs').to_s

node.normal['oracle-11g-xe'][:oracle_log_file] = node['oracle-11g-xe'][:oracle_logs_dir] + '/XEsilentinstall.log'

node.normal['oracle-11g-xe'][:oracle_rpm_path] = "#{Chef::Config[:file_cache_path]}/#{node['oracle-11g-xe'][:oracle_rpm_name]}"