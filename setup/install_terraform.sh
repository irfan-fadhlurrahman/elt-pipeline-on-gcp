echo 'Create a folder for storing downloaded file'
sleep 2
mkdir ~/bin && cd ~/bin

echo "Download and Install Terraform"
sleep 2
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

echo "Verify Installation"
terraform -help

echo "Back to previous directory"
sleep 2
cd ~/${PROJECT_FOLDER}
