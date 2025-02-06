#!/bin/bash

####
# Function to configure SSL
ssl_config() {
  # Extract the base name of the jks_file
  jks_file=$(basename "$1")

  # Check if the jks_file variable contains the word "streamlock or duckdns"
  if [[ "$jks_file" == *"streamlock"* ]]; then
    jks_domain="${jks_file%.jks}"
  elif [[ "$jks_file" == *"duckdns"* ]]; then
    jks_domain="${jks_file%.jks}"
  else
    jks_domain=""
  fi
  # Initialize duckdns variable to false
  duckdns=false
  # Capture the domain for the .jks file
  while true; do
    jks_domain=$(whiptail --title "SSL Configuration" --inputbox "Provide the domain for $jks_file file (e.g., myWowzaDomain.com):" 10 60 "$jks_domain" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ] && [ -n "$jks_domain" ]; then
        # Check if the domain contains 'duckdns.org' and set duckdns variable to true if it does
        if [[ "$jks_domain" == *"duckdns.org"* ]]; then
            duckdns=true
        fi
      break
    else
      if ! whiptail --title "SSL Configuration" --yesno "Domain input is required. Do you want to try again?" 10 60; then
        whiptail --title "SSL Configuration" --msgbox "Domain input cancelled. Continuing without SSL." 10 60
          use_ssl=false
          duckdns=false
          uploaded_jks=false
          chosen_jks_file=false
          create_docker_images
        return 1
      fi
    fi
  done

  # Capture the password for the .jks file
  while true; do
    jks_password=$(whiptail --title "SSL Configuration" --passwordbox "Please enter a .jks password (if you do not have one, please create one now):" 10 60 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ] && [ -n "$jks_password" ]; then
      break
    else
      if ! whiptail --title "SSL Configuration" --yesno "Password input is required. Do you want to try again?" 10 60; then
        whiptail --title "SSL Configuration" --msgbox "Password input cancelled. Continuing without SSL." 10 60
          use_ssl=false
          duckdns=false
          uploaded_jks=false
          chosen_jks_file=false
          create_docker_images
        return 1
      fi
    fi
  done

  # Setup Engine to use SSL for streaming and Manager access #
  # Create the tomcat.properties file
  cat <<EOL > "$container_dir/wowza/tomcat.properties"
httpsPort=8090
httpsKeyStore=/usr/local/WowzaStreamingEngine/conf/${jks_file}
httpsKeyStorePassword=${jks_password}
#httpsKeyAlias=[key-alias]
EOL
}