#!/bin/bash

mount_engine_conf () {
# Copy Wowza install directory
sudo docker cp "$container_name:/usr/local/WowzaStreamingEngine/" $container_dir/

# Replace the volume mount
sed -i 's|- engine:/usr/local/WowzaStreamingEngine|- ./WowzaStreamingEngine:/usr/local/WowzaStreamingEngine|' docker-compose.yml
# Remove the engine volume definition
sed -i '/^  engine:/,/^    driver: local$/d' docker-compose.yml

# Rebuild docker compose stack
sudo docker compose down && sudo docker compose up -d
}