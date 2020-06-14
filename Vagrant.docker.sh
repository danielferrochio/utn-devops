#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
#sudo apt-get update

# Desnstalo Apache
if [ -x "$(command -v apache2)" ]; then
  echo 'Uninstalling apache...'
  sudo service apache2 stop
  sudo apt-get remove -y apache2* 
  sudo apt autoremove -y
fi

# Instalo Docker
if ! [ -x "$(command -v docker)" ]; then
  echo 'Installing Docker...'
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli docker-compose
fi

### Configuración del entorno ###

##Genero una partición swap. Previene errores de falta de memoria
if [ ! -f "/swapdir/swapfile" ]; then
	sudo mkdir /swapdir
	cd /swapdir
	sudo dd if=/dev/zero of=/swapdir/swapfile bs=1024 count=2000000
	sudo mkswap -f  /swapdir/swapfile
	sudo chmod 600 /swapdir/swapfile
	sudo swapon swapfile
	echo "/swapdir/swapfile       none    swap    sw      0       0" | sudo tee -a /etc/fstab /etc/fstab
	sudo sysctl vm.swappiness=10
	echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
fi

cd /vagrant/
sudo docker-compose up -d

