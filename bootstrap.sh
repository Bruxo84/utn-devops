#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
sudo apt-get update

# Instalo un servidor web (Pratica 1 Expora)
sudo apt-get install -y apache2
##Desintalo el servidor web instalado previamente en la unidad 1,
# a partir de ahora va a estar en un contenedor de Docker.
if [ -x "$(command -v apache2)" ];then
	sudo apt-get remove --purge apache2 -y
	sudo apt autoremove -y
fi
# Directorio para los archivos de la base de datos MySQL. El servidor de la base de datos
# es instalado mediante una imagen de Docker. Esto está definido en el archivo
# docker-compose.yml (linea 24 y 25)
#volumes:
#      - /var/db/mysql:/var/lib/mysql
#[ -d FILE ]	True if FILE exists and is a directory.
#Si no existe ese directorio, luego lo crea 
#-p, --parents
#Crea los directorios padre que falten para cada argumento directorio.  
#Los permisos para  los  directorios  padre  se ponen a la umask modificada 
#por `u+rwx'.  No hace caso de argumentos que correspondan a directorios 
#existentes. (Así,  si  existe  un directorio /a, entonces `mkdir /a' 
#es un error, pero `mkdir -p /a' no lo es.)
if [ ! -d "/var/db/mysql" ]; then

	sudo mkdir -p /var/db/mysql
fi

# Muevo el archivo de configuración de firewall al lugar correspondiente
if [ -f "/tmp/ufw" ]; then
	sudo mv -f /tmp/ufw /etc/default/ufw
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
#Como se desinstalo Apache, No se instala esto e inclusive no se hace la
#configuracion de servidor web, ni tampoco la ruta raiz. Esta ruta raiz ahora 
#se configurara para la aplicacion
# ruta raíz del servidor web
#APACHE_ROOT="/var/www";
# ruta de la aplicación
#APP_PATH="$APACHE_ROOT/utn-devops-app";
#sudo apt-get install libapache2-mod-php7.2 php7.2 php7.2-mysql php7.2-sqlite -y
#sudo apt-get install php7.2-mbstring php7.2-curl php7.2-intl php7.2-gd php7.2-zip php7.2-bz2 -y
#sudo apt-get install php7.2-dom php7.2-xml php7.2-soap -y
## configuración servidor web
#copio el archivo de configuración del repositorio en la configuración del servidor web
#if [ -f "/tmp/devops.site.conf" ]; then
#	echo "Copio el archivo de configuracion de apache";
#	sudo mv /tmp/devops.site.conf /etc/apache2/sites-available
#	#activo el nuevo sitio web
#	sudo a2ensite devops.site.conf
#	#desactivo el default
#	sudo a2dissite 000-default.conf
#	#refresco el servicio del servidor web para que tome la nueva configuración
#	sudo service apache2 reload
#fi
## Aplicación
#configuracion de servidor web, ni tampoco la ruta raiz
# ruta raíz del servidor web
APACHE_ROOT="/var/www";
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/utn-devops-app";

# Descargo la app del repositorio
if [ ! -d "$APP_PATH" ]; then
	echo "clono el repositorio"
	cd $APACHE_ROOT
	sudo git clone https://github.com/Bruxo84/utn-devops-app.git
	cd $APP_PATH
	sudo git checkout unidad-2-docker
fi

######## Instalacion de DOCKER ########
#
# Esta instalación de docker es para demostrar el aprovisionamiento
# complejo mediante Vagrant. La herramienta Vagrant por si misma permite
# un aprovisionamiento de container mediante el archivo Vagrantfile. A fines
# del ejemplo que se desea mostrar en esta unidad que es la instalación mediante paquetes del
# software Docker este ejemplo es suficiente, para un uso más avanzado de Vagrant
# se puede consultar la documentación oficial en https://www.vagrantup.com
#
if [ ! -x "$(command -v docker)" ]; then
#[ -x FILE ]	True if FILE exists and is executable.

	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

##Configuramos el repositorio

	curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" > /tmp/docker_gpg
	#curl -fsSL 
	#-f, --fail          Fail silently (no output at all) on HTTP errors (H)
	#-s, --silent        Silent mode (don't output anything)
	#-S, --show-error    Show error. With -s, make curl show errors when they occur
	#-L, --location      Follow redirects (H)
	#Se descarga el gpg en /tmp.(pgp is a identification key system people use to 
	#"sign" files or e-mails so you can check the authenticity of them. 
	#gpg is the gnu pgp encryption program.	

	sudo apt-key add < /tmp/docker_gpg && sudo rm -f /tmp/docker_gpg
	#se agregar este GPG y luego se b:orra lo descargado en /tmp

	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	#Se agrega el repositorio en el sourcelist de un container docker Ubuntu stable
	
##Actualizo los paquetes con los nuevos repositorios
	sudo apt-get update -y

	#Instalo docker desde el repositorio oficial
	sudo apt-get install -y docker-ce docker-compose

	#Lo configuro para que inicie en el arranque
	sudo systemctl enable docker
fi
