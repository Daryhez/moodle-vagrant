$script = <<-SCRIPT
usermod -a -G docker vagrant
diff -q /etc/systemd/system/multi-user.target.wants/docker.service /home/vagrant/docker.service || cp /home/vagrant/docker.service /etc/systemd/system/multi-user.target.wants/docker.service
systemctl daemon-reload
systemctl restart docker.service
/home/vagrant/moodle-docker/bin/moodle-docker-compose up -d
SCRIPT

$environment_variables = <<-SHELL
  echo 'export MOODLE_DOCKER_WWWROOT=/home/vagrant/enterprise' >> /etc/profile.d/myvar.sh
  echo 'export MOODLE_DOCKER_DB=pgsql' >> /etc/profile.d/myvar.sh
  echo 'export MOODLE_DOCKER_WEB_HOST=moodle.docker' >> /etc/profile.d/myvar.sh
  echo 'export MOODLE_DOCKER_WEB_PORT=0.0.0.0:80' >> /etc/profile.d/myvar.sh
SHELL

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.network "private_network", ip: "192.168.100.100"
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.aliases = %w(moodle.docker)
  config.vm.synced_folder "./moodle-docker", "/home/vagrant/moodle-docker"
  config.vm.synced_folder "./moodle-enterprise", "/home/vagrant/enterprise"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--name", "moodle-docker-dev"]
    vb.cpus = 2
  end
  config.vm.provision :docker
  config.vm.provision :docker_compose
  config.vm.provision "file", source: "docker.service", destination: "/home/vagrant/docker.service"
  config.vm.provision "shell", inline: $environment_variables, run: "always"
  config.vm.provision "shell", inline: $script, run: "always"
end
