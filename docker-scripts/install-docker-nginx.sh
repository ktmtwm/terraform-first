#!/bin/sh
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker ubuntu
echo added user to docker group
docker pull nginx:latest
docker run --health-cmd='curl -sS http://127.0.0.1 || exit 1' \
    --health-timeout=10s \
    --health-retries=3 \
    --health-interval=5s \
	--name nginx -p 80:80 -d nginx 

nohup sudo docker logs -f nginx >> /tmp/nginx-health.log &
nohup sudo docker stats nginx >> /tmp/resource.html &
docker cp nginx:/usr/share/nginx/html/index.html /tmp/
python3 /tmp/calculate_words.py | sudo tee -a /tmp/index-calc.log

