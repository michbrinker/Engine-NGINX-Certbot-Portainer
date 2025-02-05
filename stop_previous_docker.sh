#!/bin/bash

# Directory containing the docker-compose.yml file
compose_dir="/path/to/your/compose/directory"
compose_file="$compose_dir/docker-compose.yml"

# Extract ports from the docker-compose.yml file
ports=$(grep -oP '(?<=ports:\n\s*- ")[^"]+' "$container_dir/docker-compose.yml")

# Check for running containers with matching ports
for port in $ports; do
  container_id=$(docker ps --filter "publish=$port" --format "{{.ID}}")
  if [ -n "$container_id" ]; then
    echo "Stopping container with ID $container_id using port $port"
    docker stop "$container_id"
  fi
done