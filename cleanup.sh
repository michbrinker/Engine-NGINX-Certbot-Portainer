####
# Function to clean up the install directory and prompt user to delete Docker images and containers
cleanup() {
echo "Cleaning up the install directory..."

  if [ -f "$upload/tomcat.properties" ]; then
    sudo rm "$upload/tomcat.properties"
  fi

  # Copy the .jks file into the wse container
  if ! $duckdns && $use_ssl; then
    sudo docker cp $upload/$jks_file $container_name:/usr/local/WowzaStreamingEngine/conf/$jks_file
  fi

  # Restart docker stack to apply changes
  cd $container_dir
  sudo docker compose restart
}