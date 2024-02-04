
ENV['VAGRANT_NO_PARALLEL'] = 'yes'
username=""
password=""
VAGRANT_BOX         = "generic/rhel9"
VAGRANT_BOX_VERSION = "4.3.12"
CPUS_MASTER_NODE    = 2
CPUS_WORKER_NODE    = 2
MEMORY_MASTER_NODE  = 2048
MEMORY_WORKER_NODE  = 4096
WORKER_NODES_COUNT  = 2

Vagrant.configure(2) do |config|

# Define master Section
    config.vm.provision "shell", path: "initialize.sh", args: [username, password]
    #config.vm.provision "file", source: "/home/amit/workarea/remote/kubernetes-setup/containerd.io-1.6.28-3.1.el9.x86_64.rpm", destination: "."
    #config.vm.provision "file", source: "/home/amit/workarea/remote/kubernetes-setup/container-selinux-2.221.0-1.el9.noarch.rpm", destination: "."
    config.vm.define "master1" do |machine|
     machine.vm.box = VAGRANT_BOX
     machine.vm.box_check_update = false
     machine.vm.box_version = VAGRANT_BOX_VERSION
     machine.vm.hostname = "master1.cloudnativeapps.in"     
     machine.vm.network "private_network", ip: "172.16.16.100"
     machine.vm.provider :virtualbox do |v|
      v.name    = "master1"
      v.memory  = MEMORY_MASTER_NODE
      v.cpus    = CPUS_MASTER_NODE
    end

    machine.vm.provider :libvirt do |v|
      v.memory  = MEMORY_MASTER_NODE
      v.nested  = true
      v.cpus    = CPUS_MASTER_NODE
    end
    machine.vm.provision "shell", path: "master.sh" , args: [username, password]

    end  
 # Define Worker Nodes
 (1..WORKER_NODES_COUNT).each do |i|
    config.vm.define "worker#{i}" do |machine|
    machine.vm.box               = VAGRANT_BOX
    machine.vm.box_check_update  = false
    machine.vm.box_version       = VAGRANT_BOX_VERSION
    machine.vm.hostname          = "worker#{i}.cloudnativeapps.in"
    machine.vm.network "private_network", ip: "172.16.16.10#{i}"
    machine.vm.provider :virtualbox do |v|
      v.name    = "worker#{i}"
      v.memory  = MEMORY_WORKER_NODE
      v.cpus    = CPUS_WORKER_NODE
    end

    machine.vm.provider :libvirt do |v|
      v.memory  = MEMORY_WORKER_NODE
      v.nested  = true
      v.cpus    = CPUS_WORKER_NODE
    end
    machine.vm.provision "shell", path: "worker.sh" , args: [username, password]
    end 
 end 
  
end    