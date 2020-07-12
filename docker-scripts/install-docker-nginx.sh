#!/bin/sh
# install docker ce
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker ubuntu
echo added user to docker group

# install nginx
docker pull nginx:latest
# start nginx with health check and volume
docker run --health-cmd='curl -sS http://127.0.0.1 || exit 1' \
    --health-timeout=10s \
    --health-retries=3 \
    --health-interval=5s \
    -v /tmp:/usr/share/nginx/html/tmp \
	--name nginx -p 80:80 -d nginx 

# change nginx configuration, show resource.log
docker cp nginx:/etc/nginx/conf.d/default.conf /tmp/
cp /tmp/default.conf /tmp/default.conf.org
head -n -2 /tmp/default.conf.org |sudo tee /tmp/default.conf
echo "location = /resource.html { root /usr/share/nginx/html/tmp;}
	  location = /health.html { root /usr/share/nginx/html/tmp;}
	  location = /words.html { root /usr/share/nginx/html/tmp;}
	  }" >> /tmp/default.conf
docker cp /tmp/default.conf nginx:/etc/nginx/conf.d/
docker restart nginx

# health check log
nohup sudo docker logs -f nginx >> /tmp/health.html &

# Resource usage log
nohup sudo docker stats nginx >> /tmp/resource.html &

# Nginx default page words count
docker cp nginx:/usr/share/nginx/html/index.html /tmp/
python3 /tmp/calculate_words.py | sudo tee -a /tmp/words.html

# Ubuntu firewall setting
ufw allow https
# ufw allow from 172.0.0.0/24 to any port 22 proto tcp Rules updated
ufw enable