maintainer       "Acquity Group"
maintainer_email "vince.montalbano@acquitygroup.com"
license          "Apache 2.0"
description      "Installs/Configures Oracle 11g Express Edition via Chef on CentOS"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.5"

recipe "chef-oracle-11g-xe", "Includes the service recipe by default."

%w{ centos }.each do |os|
  supports os
end

# depends "iptables"