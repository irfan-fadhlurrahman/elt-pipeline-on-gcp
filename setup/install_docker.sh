#!/bin/bash

echo "export all .env variables"
sleep 2
source "./.env"

echo "Update your terminal"
sleep 2
sudo apt update && sudo apt install -y wget unzip

echo "Install docker.io"
sleep 2
sudo apt install -y docker.io 

echo "To run docker without sudo"
sleep 2
sudo groupadd docker
sudo usermod -aG docker $USER

echo "Create new directory for docker-compose"
sleep 2
mkdir ~/bin

echo "Go to bin folder"
cd ~/bin

echo "Download docker-compose from Github"
sleep 2
wget "https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64" -O docker-compose

echo "Make docker-compose executable"
sleep 2
chmod +x docker-compose

echo "Add path to .bashrc"
sleep 2
echo -e '\nPATH="${HOME}/bin:${PATH}"' >> ~/.bashrc

echo "Apply the change"
sleep 2
source ~/.bashrc

echo "Back to previous directory"
sleep 2
cd ~/${PROJECT_FOLDER}