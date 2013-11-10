# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |oracle|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  oracle.vm.hostname = "oracle-standalone-vagrant"

  # Every Vagrant virtual environment requires a box to build off of.
  # oracle.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
  oracle.vm.box = "centos-6-4"


  # The url from where the 'oracle.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # oracle.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"
  oracle.vm.box_url = "http://www.dropbox.com/s/jaunwtu3g52vgj5/vagrant-centos-6-4-x64.virtualbox.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  oracle.vm.network :private_network, ip: "33.33.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.

  # oracle.vm.network :public_network

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # oracle.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # oracle.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # The path to the Berksfile to use with Vagrant Berkshelf
  # oracle.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  oracle.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # oracle.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # oracle.berkshelf.except = []

  oracle.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks"]
      chef.add_recipe "oracle-11g-xe"

      chef.json.merge!({
        'oracle-11g-xe' => {
          'rpm_url' => 'https://www.dropbox.com/s/w9lz8j5td1evadc/oracle-xe-11.2.0-1.0.x86_64.rpm'
        }
      })
  end
end
