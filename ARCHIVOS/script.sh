#! /bin/bash
sudo systemctl enable apache2
sudo systemctl start apache2 
sudo useradd -m www-data
echo "ssi{$echo "$RANDOM" | md5sum | head -c 13)}" > /home/www-data/user.txt
echo "ssi{$echo "$RANDOM" | md5sum | head -c 13)}" > /root/root.txt
