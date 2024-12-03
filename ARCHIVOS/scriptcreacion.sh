#!/bin/bash

# Variables
DB_NAME="vulnerable_db"
DB_USER="mysqluser"
DB_PASS="ssi2024"
WEB_DIR="/var/www/html/pagina"
REPO_URL="https://github.com/ireneromsaduni/FINAL-SSI.git"

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
sudo apt install -y apache2 mysql-server git
check_error "Error al instalar Apache, MySQL o Git"



# Habilitar servicios
echo "Habilitando servicios de Apache y MySQL..."
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl start apache2
sudo systemctl start mysql

sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$ROOT_PASS'; FLUSH PRIVILEGES;"
check_error "Error al configurar contraseña de root en MySQL"

# Configurar la base de datos
echo "Creando usuario y base de datos en MySQL..."
sudo mysql -uroot -p$mysql_native_password <<EOF

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
INSERT INTO users (username, password) VALUES ('user', 'user123')
    ON DUPLICATE KEY UPDATE username=username;
EOF
check_error "Error al configurar usuario y base de datos en MySQL"

echo "Base de datos creada y configurada."

# Descargar la página web desde un repositorio
echo "Clonando el repositorio de la página web..."
sudo mkdir -p $WEB_DIR
sudo git clone $REPO_URL $WEB_DIR
check_error "Error al clonar el repositorio"s

# Asegurar permisos para www-data
echo "Configurando permisos para www-data..."
sudo chown -R www-data:www-data $WEB_DIR
sudo chmod -R 755 $WEB_DIR
check_error "Error al configurar permisos para la página web"

# Configurar Firewall para permitir tráfico HTTP y HTTPS
echo "Configurando Firewall para permitir tráfico web..."
sudo ufw allow 'Apache Full'
sudo ufw --force enable
check_error "Error al configurar el Firewall"

# Reiniciar Apache para aplicar cambios
echo "Reiniciando Apache..."
sudo systemctl restart apache2
check_error "Error al reiniciar Apache"

echo "¡Todo listo! Tu página web debería estar funcionando."
