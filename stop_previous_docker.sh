#!/bin/bash

# Function to stop docker containers that have the same ports as the compose stack
stop_previous_docker() {
  # Extract ports from the docker-compose.yml file
  ports=$(grep -oP 'ports:\n\s*-\s*\K[0-9]+' "$container_dir/docker-compose.yml")

  # Check for running containers with matching ports
  for port in $ports; do
    container_id=$(docker ps --filter "publish=$port" --format "{{.ID}}")
    if [ -n "$container_id" ]; then
      echo "Stopping container with ID $container_id using port $port"
      docker stop "$container_id"
    fi
  done
}