#! /bin/bash

# Asegurarse de que Apache está habilitado e iniciado
systemctl enable apache2
systemctl start apache2 

# Crear usuario www-data si no existe
id -u www-data &>/dev/null || useradd -m www-data

# Asegurarse de que el directorio home de www-data exista
if [ ! -d "/home/www-data" ]; then
    mkdir /home/www-data
    chown www-data:www-data /home/www-data
    chmod 700 /home/www-data
fi

# Generar y escribir la flag para www-data
FLAG=$(echo "ssi{$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)}")
echo "$FLAG" > /home/www-data/user.txt
chown www-data:www-data /home/www-data/user.txt
chmod 600 /home/www-data/user.txt

# Generar y escribir la flag para root
FLAG=$(echo "ssi{$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)}")
echo "$FLAG" > /root/root.txt
chown root:root /root/root.txt
chmod 600 /root/root.txt
