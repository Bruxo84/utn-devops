#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
sudo apt-get update

# Instalo un servidor web
sudo apt-get install -y apache2 

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

## configuración servidor web
#copio el archivo de configuración del repositorio en la configuración del servidor web
if [ -f "/tmp/devops.site.conf" ]; then
	echo "Copio el archivo de configuracion de apache";
	sudo mv /tmp/devops.site.conf /etc/apache2/sites-available
	#activo el nuevo sitio web
	sudo a2ensite devops.site.conf
	#desactivo el default
	sudo a2dissite 000-default.conf
	#refresco el servicio del servidor web para que tome la nueva configuración
	sudo service apache2 reload
fi
	
## aplicación

# descargo la app del repositorio
if [ ! -d "$APP_PATH" ]; then
	echo "clono el repositorio";
	cd $APACHE_ROOT;
	sudo git clone https://github.com/Bruxo84/utn-devops/utn-devops-app.git;
	cd $APP_PATH;
	sudo git checkout unidad-1;
fi
