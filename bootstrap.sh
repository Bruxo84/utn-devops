#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
sudo apt-get update

# Instalo un servidor web
sudo apt-get install -y apache2 
rm -rf /var/www
ln -fs /vagrant /var/www

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

# ruta raíz del servidor web
APACHE_ROOT="/var/www";
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/utn-devops-app";


sudo apt-get install libapache2-mod-php7.2 php7.2 php7.2-mysql php7.2-sqlite -y
sudo apt-get install php7.2-mbstring php7.2-curl php7.2-intl php7.2-gd php7.2-zip php7.2-bz2 -y
sudo apt-get install php7.2-dom php7.2-xml php7.2-soap -y

# Reiniciamos el servidor web:
 
sudo /etc/init.d/apache2 restart
 
echo "BRUXO84 localhost" | sudo tee /etc/apache2/sites-available/fqdn.conf
 
sudo ln -s /etc/apache2/sites-available/fqdn.conf /etc/apache2/sites-enabled/fqdn.conf
 
# Reiniciamos nuevamente el servidor web:
 
sudo /etc/init.d/apache2 restart