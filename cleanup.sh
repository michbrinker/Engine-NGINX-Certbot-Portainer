#!/bin/bash

####
# Function to clean up the install directory and prompt user to delete Docker images and containers
cleanup() {
echo "Cleaning up the install directory..."

  #if [ -f "$upload/tomcat.properties" ]; then
  #  sudo rm "$upload/tomcat.properties"
  #fi

  # Restart docker stack to apply changes
  cd $container_dir
  sudo docker compose restart
}