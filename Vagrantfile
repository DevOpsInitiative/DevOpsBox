Vagrant.configure(2) do |config|
	config.vm.define "cibox" do |cibox|
		cibox.vm.box = "bento/centos-7"
		#cibox.vm.network "private_network", ip: "192.168.199.9"
		cibox.vm.hostname = "cibox"
		config.vm.network "forwarded_port", guest: 8080, host: 8880
		config.vm.network "forwarded_port", guest: 5555, host: 5555
		config.vm.network "forwarded_port", guest: 9999, host: 9999
		cibox.vm.provision "shell", path: "scripts/install_ci.sh"
		cibox.vm.provider "virtualbox" do |v|
			v.memory = 4096
			v.cpus = 2
		end
	end
	config.vm.define "ldbox" do |ldbox|
		ldbox.vm.box = "bento/centos-7"
		#ldbox.vm.network "private_network", ip: "192.168.199.9"
		ldbox.vm.hostname = "ldbox"
		config.vm.network "forwarded_port", guest: 5555, host: 6666
	  	ldbox.vm.provision "shell", path: "scripts/install_ld.sh"
		ldbox.vm.provider "virtualbox" do |v|
			v.memory = 4096
			v.cpus = 2
		end
	end
end
