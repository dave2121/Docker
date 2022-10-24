#!/bin/bash
sudo apt update -y
# Uninstall Docker Engine
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
# Install Docker Engine on Ubuntu
sudo apt update -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" <<-EOF
ENTER
EOF
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo docker --version