
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

VAGRANT_BOX         = "generic/rhel9"
VAGRANT_BOX_VERSION = "4.3.12"
CPUS_MASTER_NODE    = 2
CPUS_WORKER_NODE    = 1
MEMORY_MASTER_NODE  = 2048
MEMORY_WORKER_NODE  = 1024
WORKER_NODES_COUNT  = 2

Vagrant.configure(2) do |config|
    config.vm.box = "generic/rhel9"
    config.vm.network "private_network", ip: "172.16.16.100"
    config.vm.provider :libvirt do |v|
        #v.customize ['modifyvm', :id, '--cableconnected1', 'on']
        v.memory  = MEMORY_MASTER_NODE
        v.nested  = true
        v.cpus    = CPUS_MASTER_NODE
      end
    config.vm.provision "shell", path: "initialize.sh"
    
  
end    