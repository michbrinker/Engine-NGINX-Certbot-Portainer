#!/bin/bash

####
# Function to create docker-compose.yml and run docker compose up
compose() {

# Locate previous volumes
# Generate stack name variable for this install
stack_name=$(echo "$container_name" | tr -d '.') 

# Find volumes matching the pattern
volumes=$(sudo docker volume ls -q | grep "${stack_name}_engine")
volumesP=$(sudo docker volume ls -q  | grep "${stack_name}_portainer_data")

if [ -n "$volumesP" ]; then
    for volume in $volumesP; do
    sudo docker volume rm "$volume"
    done
fi

if [ -n "$volumes" ]; then
    for volume in $volumes; do
        # Ask the user if they want to remove the volume
        if whiptail --yes-button "Remove" --no-button "Keep" --yesno "Old volume matching ${stack_name}_engine found: $volume.\nDo you want to remove it to install the new Docker stack?\nKeeping the old volume with retain the previous configuration of the Engine install." 20 60; then
            sudo docker volume rm "$volume"
            whiptail --msgbox "Volume $volume was removed." 10 60
        else
            whiptail --msgbox "Volume $volume was kept. The previous configuration of Wowza Streaming Engine will be used." 10 60
        fi
    done
fi

  # Create docker-compose.yml
  cat <<EOL > "$container_dir/docker-compose.yml"
services:
  certbot_dns_duckdns:
    container_name: ${container_name}_certbot
    volumes:
      - $container_dir/certbot/letsencrypt:/etc/letsencrypt
      - $container_dir/certbot/log/letsencrypt:/var/log/letsencrypt
      - $container_dir/certbot/duckdns.ini:/conf/duckdns.ini
    image: infinityofspace/certbot_dns_duckdns:latest
    command: certonly --non-interactive --agree-tos --email $SSL_EMAIL
      --preferred-challenges dns --authenticator dns-duckdns
      --dns-duckdns-credentials /conf/duckdns.ini
      --dns-duckdns-propagation-seconds 60 -d "$jks_domain"
  nginx:
    container_name: ${container_name}_nginx
    image: docker.io/library/nginx:${engine_version}
    ports:
      - 80:80
      - 444:443
    volumes:
      - $container_dir/nginx/config:/etc/nginx
      - $container_dir/nginx/www:/var/www/html
      - $container_dir/certbot/letsencrypt/archive/$jks_domain:/etc/nginx/ssl
    restart: unless-stopped
  wowza:
    container_name: ${container_name}
    image: docker.io/library/wowza_engine:${engine_version}
    restart: always
    ports:
      - "6970-7000:6970-7000/udp"
      - "443:443"
      - "1935:1935"
      - "554:554"
      - "8084-8090:8084-8090/tcp" 
    volumes:
      - engine:/usr/local/WowzaStreamingEngine
      - $container_dir/certbot/letsencrypt:/usr/local/WowzaStreamingEngine/conf/ssl
      - $container_dir/nginx/www:/usr/local/WowzaStreamingEngine/www
    entrypoint: /sbin/entrypoint.sh
    env_file: 
      - ./.env
    environment:
      - WSE_LIC=${WSE_LIC}
      - WSE_MGR_USER=${WSE_MGR_USER}
      - WSE_MGR_PASS=${WSE_MGR_PASS}
  portainer:
    image: portainer/portainer-ce:latest
    container_name: ${container_name}_portainer
    ports:
      - 9443:9443
      - 8000:9000
    volumes:
      - $container_dir/certbot/letsencrypt:/certs:ro
      - portainer_data:/data
      - /var/run/docker.sock:/var/run/docker.sock
EOL
    # Conditionally add SSL command block
  if $use_ssl; then
    cat <<EOL >> "$container_dir/docker-compose.yml"
    command: |-
      --sslcert /certs/live/$jks_domain/fullchain.pem
      --sslkey /certs/live/$jks_domain/privkey.pem
EOL
  fi

  cat <<EOL >> "$container_dir/docker-compose.yml"
    restart: unless-stopped
volumes:
  portainer_data:
    driver: local
  engine:
    driver: local
EOL

  # Run docker compose up
  cd "$container_dir"
  sudo docker compose up -d

  # Wait for the services to start and print logs
  echo "Waiting for services to start..."
  sleep 1  # Adjust the sleep time as needed

  echo "Printing docker compose logs..."
  sudo docker compose logs
}
