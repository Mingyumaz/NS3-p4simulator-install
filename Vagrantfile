# -*- mode: ruby -*-
# vi: set ft=ruby :

###############
#  Variables  #
###############

CPUS = 4
# - 8GB RAM SHOULD be sufficient for most examples and applications.
# - Reduce the memory number (in MB) here if you physical machine does not have enough physical memory.
RAM = 8192

# Bento: Packer templates for building minimal Vagrant baseboxes
# The bento/ubuntu-XX.XX is a small image of about 900 MB, fast to download
BOX = "bento/ubuntu-22.04"
VM_NAME = "ubuntu-22.04-p4simulator"

# When using libvirt as the provider, use this box, bento boxes do not support libvirt.
# BOX_LIBVIRT = "generic/ubuntu2004"

######################
#  Provision Script  #
######################

# Common bootstrap
$bootstrap= <<-SCRIPT
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

APT_PKGS=(
  ansible
  bash-completion
  dfc
  gdb
  git
  htop
  iperf
  iperf3
  make
  pkg-config
  python3
  python3-dev
  python3-pip
  sudo
  tmux
)
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${APT_PKGS[@]}"
SCRIPT

# $setup_x11_server= <<-SCRIPT
# APT_PKGS=(
#   openbox
#   xauth
#   xorg
#   xterm
# )
# DEBIAN_FRONTEND=noninteractive apt-get update
# DEBIAN_FRONTEND=noninteractive apt-get install -y "${APT_PKGS[@]}"
# SCRIPT

$setup_p4simulator= <<-SCRIPT
# Apply a custom Xterm profile that looks better than the default.
# cp /home/vagrant/p4simulator/util/Xresources /home/vagrant/.Xresources
# xrdb can not run directly during vagrant up. Auto-works after reboot.
# xrdb -merge /home/vagrant/.Xresources

cd /home/vagrant/p4simulator/util || exit
bash ./install_env.sh -a

# Run the custom shell script, if it exists.
cd /home/vagrant/p4simulator/util || exit
if [ -f "./vm_customize.sh" ]; then
  echo "*** Run VM customization script."
  bash ./vm_customize.sh
fi
SCRIPT


####################
#  Vagrant Config  #
####################

Vagrant.configure("2") do |config|

  config.vm.define "p4simulator" do |p4simulator|
    p4simulator.vm.box = BOX
    # Sync ./ to home directory of vagrant to simplify the install script
    p4simulator.vm.synced_folder ".", "/vagrant", disabled: true
    p4simulator.vm.synced_folder ".", "/home/vagrant/p4simulator"

    # For Virtualbox provider
    p4simulator.vm.provider "virtualbox" do |vb|
      vb.name = VM_NAME
      vb.cpus = CPUS
      vb.memory = RAM
      # MARK: The vCPUs should have SSE4 to compile DPDK applications.
      # vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
      # vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]
    end

    # For libvirt provider
    p4simulator.vm.provider "libvirt" do |libvirt, override|
      # Overrides are used to modify default options that do not work for libvirt provider.
      override.vm.box = BOX_LIBVIRT
      override.vm.synced_folder ".", "/home/vagrant/p4simulator", type: "nfs", nfs_version: 4

      libvirt.driver = "kvm"
      libvirt.cpus = CPUS
      libvirt.memory = RAM
    end

    p4simulator.vm.hostname = "p4simulator"
    p4simulator.vm.box_check_update = true
    p4simulator.vm.post_up_message = '
The VM is up! Run "$ vagrant ssh p4simulator" to ssh into the running VM.

IMPORTANT! For all p4simulator users and developers:

When a new version is released (https://git.comnets.net/public-repo/comnetsemu/-/tags),
please run the upgrade process described [here](https://git.comnets.net/public-repo/comnetsemu#upgrade-comnetsemu-and-dependencies).
New features, fixes and other improvements require **manually** running the upgrade script.
But the script will automatically check and perform the upgrade, and if you have a good internet connection,
it will not take much time.
    '

    comnetsemu.vm.provision :shell, inline: $bootstrap, privileged: true
    comnetsemu.vm.provision :shell, inline: $setup_x11_server, privileged: true
    comnetsemu.vm.provision :shell, inline: $setup_comnetsemu, privileged: false
    comnetsemu.vm.provision :shell, inline: $post_installation, privileged: true

    comnetsemu.vm.provider "libvirt" do |libvirt, override|
      override.vm.provision :shell, inline: $setup_libvirt_vm_always, privileged: true, run: "always"
    end
    comnetsemu.vm.provision :shell, privileged:false, run: "always", path: "./util/echo_banner.sh"

    # VM networking
    comnetsemu.vm.network "forwarded_port", guest: 8888, host: 8888, host_ip: "127.0.0.1"
    comnetsemu.vm.network "forwarded_port", guest: 8082, host: 8082
    comnetsemu.vm.network "forwarded_port", guest: 8083, host: 8083
    comnetsemu.vm.network "forwarded_port", guest: 8084, host: 8084

    # - Uncomment the underlying line to add a private network to the VM.
    #   If VirtualBox is used as the hypervisor, this means adding or using (if already created) a host-only interface to the VM.
    # comnetsemu.vm.network "private_network", ip: "192.168.0.2"

    # Enable X11 forwarding
    comnetsemu.ssh.forward_agent = true
    comnetsemu.ssh.forward_x11 = true
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
