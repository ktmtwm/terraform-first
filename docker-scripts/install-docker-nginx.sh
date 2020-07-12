#!/bin/sh
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker ubuntu
echo added user to docker group
docker pull nginx:latest
docker run --name nginx -p 80:80 -d nginx