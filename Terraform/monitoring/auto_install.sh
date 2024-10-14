#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
sudo groupadd docker
sudo usermod -aG docker $USER
sudo apt-get install -y curl git jq
curl -sfL https://get.k3s.io | sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic-archive-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt update
sudo apt install filebeat
ssh-keygen -t rsa -b 4096 -C "github-key" -N ""
curl -u "AndrewKrmn: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" \
  --data '{"title":"My SSH Key","key":"'"$(cat ~/.ssh/id_rsa.pub)"'"}' \
  https://api.github.com/user/keys
ssh -T git@github.com
git clone git@github.com:AndrewKrmn/diplom.git
cd diplom/
docker compose up -d
cd Terraform/k8s/
kubectl apply -f deployment.yaml