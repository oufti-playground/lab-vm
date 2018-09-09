Vagrant.configure("2") do |config|

  config.ssh.username = "alpine"
  config.ssh.shell = "bash -l"

  config.vm.provider "virtualbox" do |vm, override|

    # Custom VM configuration
    vm.customize ["modifyvm", :id, "--memory", "4096"]
    vm.customize ["modifyvm", :id, "--cpus", "2"]
    vm.customize ["modifyvm", :id, "--cableconnected1", "on"]
    vm.customize ["modifyvm", :id, "--audio", "none"]
    vm.customize ["modifyvm", :id, "--usb", "off"]
    # For secured workstations
    vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

    # Port forwarding
    if ENV["EXTERNAL_PORT"]
        override.vm.network "forwarded_port", guest: ENV["EXTERNAL_PORT"], host: ENV["EXTERNAL_PORT"], id: "http"
        config.vm.provision "shell", inline: "sed -i s/EXTERNAL_PORT=.*$/EXTERNAL_PORT=/" +
            ENV["EXTERNAL_PORT"] + " /var/customize/.env"
    else
        override.vm.network "forwarded_port", guest: 80, host: 80, auto_correct: true, id: "http"
    end

    # No FS share to allow any depds to the host
    config.vm.synced_folder ".", "/vagrant", disabled: true
  end

end
