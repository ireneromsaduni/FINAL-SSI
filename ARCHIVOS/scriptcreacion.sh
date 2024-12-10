#!/bin/bash

# Variables
DB_NAME="vulnerable_db"
DB_USER="mysqluser"
DB_PASS="ssi2024"
WEB_DIR="/var/www/html/pagina"
REPO_URL="https://github.com/ireneromsaduni/FINAL-SSI.git"
MYSQL_ROOT_PASS="user1"
ARCHIVOS_DIR="$WEB_DIR/ARCHIVOS"

function check_error {
    if [ $? -ne 0 ]; then
        echo "Error: $1. Abortando."
        exit 1
    fi
}

# Actualizar e instalar Apache y MySQL
echo "Actualizando e instalando paquetes necesarios..."
sudo apt update -y && sudo apt upgrade -y
check_error "Error al actualizar paquetes"
sudo DEBIAN_FRONTEND=noninteractive apt install -y gnupg wget ufw
check_error "Error instalando gnupg o wget o ufw o php"
echo "Instalado gnupg y wget"

echo "Instalando paquete MySQL..."

# Evitar la interacción durante la instalación de MySQL
echo "mysql-server-8.0 mysql-server/root_password password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
echo "mysql-server-8.0 mysql-server/root_password_again password $MYSQL_ROOT_PASS" | sudo debconf-set-selections

wget https://dev.mysql.com/get/mysql-apt-config_0.8.30-1_all.deb
sudo DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.30-1_all.deb <<< "mysql-8.0"
sudo apt update

# Instalación de MySQL sin interacción
echo "Instalando mysql-server, apache2 y git..."
sudo DEBIAN_FRONTEND=noninteractive apt install php apache2 libapache2-mod-php8.2 php-common php8.2 php8.2-cli php8.2-common php8.2-opcache php8.2-readline git patch apache2-data apache2-utils git-man liberror-perl 
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server 
check_error "Error al instalar Apache, MySQL o Git"

echo "INSTALADO MYSQL ETC"

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install php
check_error "Error instalando php"
echo "Instalado php"

sudo DEBIAN_FRONTEND=noninteractive apt-get install php-mysqli
echo "Instalado php-mysqli"

sudo DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends binutils binutils-common binutils-x86-64-linux-gnu gcc gcc-12 libasan8 libbinutils libcc1-0 libctf-nobfd0 libctf0 libgcc-12-dev libgprofng0 libitm1 liblsan0 libtsan2 libubsan1  
echo "Instalado gcc"

# Habilitar servicios
echo "Habilitando servicios de Apache y MySQL..."
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl start apache2
sudo systemctl start mysql

# Configurar la base de datos
echo "Creando usuario y base de datos en MySQL..."
sudo mysql -u root -p$MYSQL_ROOT_PASS <<EOF

-- Crear un usuario con nombre y contraseña definidos en las variables
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
-- Otorgar todos los privilegios al nuevo usuario
GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS $DB_NAME;
USE $DB_NAME;

-- Crear la tabla 'users'
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL
);

-- Insertar datos iniciales en la tabla 'users'
INSERT INTO users (username, password) VALUES ('admin', 'admin123')
    ON DUPLICATE KEY UPDATE username=username; -- Evitar duplicados
INSERT INTO users (username, password) VALUES ('user1', 'user123')
    ON DUPLICATE KEY UPDATE username=username;
INSERT INTO users (username, password) VALUES ('user2', 'user123')
    ON DUPLICATE KEY UPDATE username=username;
INSERT INTO users (username, password) VALUES ('user3', 'user123')
    ON DUPLICATE KEY UPDATE username=username;
INSERT INTO users (username, password) VALUES ('user4', 'user123')
    ON DUPLICATE KEY UPDATE username=username;
EOF
check_error "Error al configurar usuario y base de datos en MySQL"

echo "Base de datos creada y configurada."

# Descargar la página web desde un repositorio
echo "Clonando el repositorio de la página web..."
sudo rm -r $WEB_DIR
sudo mkdir -p $WEB_DIR
sudo git clone $REPO_URL $WEB_DIR
check_error "Error al clonar el repositorio"

# Asegurar permisos para www-data
echo "Configurando permisos para www-data..."
sudo chown -R www-data:www-data $WEB_DIR
sudo chmod -R 755 $WEB_DIR
check_error "Error al configurar permisos para la página web"

# Configurar el script.sh y script.service
echo "Configurando script.sh y script.service..."
SCRIPT_PATH="$ARCHIVOS_DIR/script.sh"
SERVICE_PATH="$ARCHIVOS_DIR/script.service"
TARGET_SERVICE_PATH="/etc/systemd/system/script.service"

if [ -f "$SCRIPT_PATH" ]; then
    # Dar permisos de ejecución a script.sh
    sudo chmod +x $SCRIPT_PATH
    check_error "Error al dar permisos de ejecución a script.sh"
else
    echo "Error: $SCRIPT_PATH no encontrado. Abortando."
    exit 1
fi

if [ -f "$SERVICE_PATH" ]; then
    # Copiar script.service a systemd
    sudo cp $SERVICE_PATH $TARGET_SERVICE_PATH
    check_error "Error al copiar script.service a /etc/systemd/system"
else
    echo "Error: $SERVICE_PATH no encontrado. Abortando."
    exit 1
fi



# Activar y habilitar el servicio
sudo systemctl daemon-reload
check_error "Error al recargar systemd"
sudo systemctl enable script.service
check_error "Error al habilitar script.service"
sudo systemctl start script.service
check_error "Error al iniciar script.service"
echo "script.sh y script.service configurados y habilitados correctamente."

echo "www-data ALL=(ALL) NOPASSWD: /usr/bin/gcc" | sudo tee -a /etc/sudoers > /dev/null

# Reiniciar Apache para aplicar cambios
echo "Reiniciando Apache..."
sudo systemctl restart apache2
check_error "Error al reiniciar Apache"

echo "¡Todo listo! Tu página web debería estar funcionando."
