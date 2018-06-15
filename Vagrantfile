Vagrant.configure(2) do |config|
	config.vm.define "devops-box" do |devbox|
		devbox.vm.box = "bento/centos-7"
    		#devbox.vm.network "private_network", ip: "192.168.199.9"
    		#devbox.vm.hostname = "devops-box"
		config.vm.network "forwarded_port", guest: 8080, host: 8880
		config.vm.network "forwarded_port", guest: 5555, host: 5555
		config.vm.network "forwarded_port", guest: 9999, host: 9999
      		devbox.vm.provision "shell", path: "scripts/install.sh"
    		devbox.vm.provider "virtualbox" do |v|
    		  v.memory = 4096
    		  v.cpus = 2
    		end
	end
end
