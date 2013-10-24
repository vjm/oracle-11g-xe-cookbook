node.default["oracle-11g-ee"][:temp_dir] = "/oracle_tmp"
node.default["oracle-11g-ee"][:pack_list] = ["libaio", "bc", "flex", "zip", "unzip", "wget"]

node.default["oracle-11g-ee"][:rpm_url] = nil

node.default["oracle-11g-ee"][:oracle_http_port] = 8080
node.default["oracle-11g-ee"][:oracle_listener_port] = 1521
node.default["oracle-11g-ee"][:oracle_password] = "vagrant"
node.default["oracle-11g-ee"][:oracle_dbenable] = true

node.default["oracle-11g-ee"][:oracle_env_path] = "/u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh"
node.default['oracle-11g-ee'][:oracle_daemon] = "/etc/init.d/oracle-xe"

node.default['oracle-11g-ee'][:listener_ora] = "/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora"
node.default['oracle-11g-ee'][:tnsnames_ora] = "/u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora"

node['oracle-11g-ee'][:host_only_interface] = "eth1"