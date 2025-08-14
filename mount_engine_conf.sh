#!/bin/bash


mount_engine_conf () {
# Copy Wowza install directory, resolving symlinks if necessary
wowza_path="/usr/local/WowzaStreamingEngine"
is_symlink=$(sudo docker exec "$container_name" test -L "$wowza_path" && echo yes || echo no)
if [ "$is_symlink" = "yes" ]; then
	# Resolve the symlink target inside the container
	real_path=$(sudo docker exec "$container_name" readlink -f "$wowza_path")
	echo "[INFO] $wowza_path is a symlink. Copying real directory: $real_path"
	sudo docker cp "$container_name:$real_path/." "$container_dir/WowzaStreamingEngine/"
else
	sudo docker cp "$container_name:$wowza_path/." "$container_dir/WowzaStreamingEngine/"
fi


# Replace the volume mount
sed -i 's|- engine:/usr/local/WowzaStreamingEngine|- ./WowzaStreamingEngine:/usr/local/WowzaStreamingEngine|' docker-compose.yml
# Remove the engine volume definition
sed -i '/^  engine:/,/^    driver: local$/d' docker-compose.yml

# Rebuild docker compose stack
sudo docker compose down && sudo docker compose up -d
}