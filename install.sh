#!/bin/bash
#Docker install
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
#Jenkins install
sudo chmod 666 /var/run/docker.sock
docker run -d --name jenkins --restart always --network jenkins-network -p 8082:8080 -p 50000:50000 -v /usr/bin/docker:/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock -v /home/andrew/diplom/jenkins_home:/var/jenkins_home -v /home/andrew/diplom/generate_ssh_keys.sh:/usr/local/bin/generate_ssh_keys.sh --entrypoint /usr/local/bin/generate_ssh_keys.sh --privileged jenkins/jenkins:lts
