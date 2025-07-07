#!/bin/bash

mount_engine_conf () {
  # Create target directory with proper permissions
  sudo mkdir -p $container_dir/WowzaStreamingEngine
  sudo chmod 777 $container_dir/WowzaStreamingEngine

  # Use tar method which preserves permissions better than direct cp
  echo "Creating temporary archive of Wowza configuration..."
  sudo docker exec $container_name bash -c "cd /usr/local && tar -czf /tmp/wowza_backup.tar.gz WowzaStreamingEngine"
  sudo docker cp "$container_name:/tmp/wowza_backup.tar.gz" $container_dir/
  
  echo "Extracting Wowza configuration..."
  sudo tar -xzf $container_dir/wowza_backup.tar.gz -C $container_dir/
  sudo rm $container_dir/wowza_backup.tar.gz
  
  # Ensure correct permissions
  sudo chmod -R 755 $container_dir/WowzaStreamingEngine
  
  # Replace the volume mount
  sed -i 's|- engine:/usr/local/WowzaStreamingEngine|- ./WowzaStreamingEngine:/usr/local/WowzaStreamingEngine|' docker-compose.yml
  # Remove the engine volume definition
  sed -i '/^  engine:/,/^    driver: local$/d' docker-compose.yml

  # Rebuild docker compose stack
  sudo docker compose down && sudo docker compose up -d
  
  echo "Wowza configuration mounted successfully"
}