#!/bin/bash

#Set colors to Wowza colors
w='\033[38;5;208m'
NOCOLOR='\033[0m'
yellow='\033[38;5;226m'
white='\033[38;5;15m'

# Set message box colors
export NEWT_COLORS='
root=,black'

# Display info box about the script and function scripts
whiptail --title "Docker Engine Workflow Installer" --msgbox "
Welcome to the Docker Engine Workflow Installer!\n\nThis installation script automates the deployment of\n\n - Wowza Streaming Engine\n\n - SWAG (simple webserver and SSL bot)\n\n - Portainer (docker management tool)\n\nin a Docker stack." 20 75

#
## Set directory variables and create the directories

# Get the directory of the script file and set varilable
SCRIPT_DIR=$(realpath $(dirname "$0"))

# Define the build directory
encp="$SCRIPT_DIR/encp"
mkdir -p -m 777 "$encp"

# Define the upload directory
upload="$encp/upload"
mkdir -p -m 777 "$upload"

# URL of the Functions Scripts
DEPENDENCIES_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/dependencies.sh"
FETCH_AND_SET_WOWZA_VERSIONS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/fetch_and_set_wowza_versions.sh"
CHECK_FOR_JKS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/check_for_jks.sh"
UPLOAD_JKS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/upload_jks.sh"
DUCKDNS_CREATE_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/duckDNS_create.sh"
SSL_CONFIG_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/ssl_config.sh"
CREATE_DOCKER_IMAGES_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/create_docker_images.sh"
CREDENTIALS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/credentials.sh"
COMPOSE_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/compose.sh"
CONVERT_JKS_TO_PEM_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/convert_jks_to_pem.sh"
CONVERT_PEM_TO_JKS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/convert_pem_to_jks.sh"
SWAGGER="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/swagger.sh"
CLEANUP_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/cleanup.sh"
CREATE_HTML_INSTRUCTIONS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/create_html_instructions.sh"

# Download the Functions Scripts
curl -o "$encp/dependencies.sh" "$DEPENDENCIES_URL" > /dev/null 2>&1
curl -o "$encp/fetch_and_set_wowza_versions.sh" "$FETCH_AND_SET_WOWZA_VERSIONS_URL" > /dev/null 2>&1
curl -o "$encp/check_for_jks.sh" "$CHECK_FOR_JKS_URL" > /dev/null 2>&1
curl -o "$encp/upload_jks.sh" "$UPLOAD_JKS_URL" > /dev/null 2>&1
curl -o "$encp/duckDNS_create.sh" "$DUCKDNS_CREATE_URL" > /dev/null 2>&1
curl -o "$encp/ssl_config.sh" "$SSL_CONFIG_URL" > /dev/null 2>&1
curl -o "$encp/create_docker_images.sh" "$CREATE_DOCKER_IMAGES_URL" > /dev/null 2>&1
curl -o "$encp/credentials.sh" "$CREDENTIALS_URL" > /dev/null 2>&1
curl -o "$encp/compose.sh" "$COMPOSE_URL" > /dev/null 2>&1
curl -o "$encp/convert_jks_to_pem.sh" "$CONVERT_JKS_TO_PEM_URL" > /dev/null 2>&1
curl -o "$encp/convert_pem_to_jks.sh" "$CONVERT_PEM_TO_JKS_URL" > /dev/null 2>&1
curl -o "$encp/swagger.sh" "$SWAGGER" > /dev/null 2>&1
curl -o "$encp/create_html_instructions.sh" "$CREATE_HTML_INSTRUCTIONS_URL" > /dev/null 2>&1
curl -o "$encp/cleanup.sh" "$CLEANUP_URL" > /dev/null 2>&1

# Source for the Functions Scripts
source "$encp/dependencies.sh"
source "$encp/fetch_and_set_wowza_versions.sh"
source "$encp/check_for_jks.sh"
source "$encp/upload_jks.sh"
source "$encp/duckDNS_create.sh"
source "$encp/ssl_config.sh"
source "$encp/create_docker_images.sh"
source "$encp/credentials.sh"
source "$encp/compose.sh"
source "$encp/convert_jks_to_pem.sh"
source "$encp/convert_pem_to_jks.sh"
source "$encp/swagger.sh"
source "$encp/create_html_instructions.sh"
source "$encp/cleanup.sh"

dependencies
fetch_and_set_wowza_versions
if [ $? -ne 0 ]; then
  echo -e "${w}Installation cancelled by user."
  exit 1
fi
check_for_jks # runs upload_jks, ssl_config, duckDNS_create
create_docker_images
credentials 
compose

# Create symlinks for Engine directories
sudo ln -sf /var/lib/docker/volumes/${stack_name}_engine/_data/conf/ $container_dir/Engine_conf
sudo ln -sf /var/lib/docker/volumes/${stack_name}_engine/_data/logs/ $container_dir/Engine_logs
sudo ln -sf /var/lib/docker/volumes/${stack_name}_engine/_data/content/ $container_dir/Engine_content
sudo ln -sf /var/lib/docker/volumes/${stack_name}_engine/_data/transcoder/ $container_dir/Engine_transcoder
sudo ln -sf /var/lib/docker/volumes/${stack_name}_engine/_data/manager/ $container_dir/Engine_manager
sudo ln -sf /var/lib/docker/volumes/${stack_name}_engine/_data/lib /$container_dir/Engine_lib

if $duckdns; then
  convert_pem_to_jks "$jks_domain" "$jks_password" "$jks_password"
fi
if ! $duckdns; then
  convert_jks_to_pem
fi

swagger
cleanup
create_html_instructions

if $use_ssl; then
echo -e "${w}For instructions on using the installed software, please visit ${yellow}https://$jks_domain:444/instructions.html${NOCOLOR}"
else
echo -e "${w}For instructions on using the installed software, please open ${yellow}$container_dir/www/instructions.html${NOCOLOR}"
fi

# Prompt user to delete installer script
if whiptail --title "Installation complete" --yesno "The installer has completed the installation of 
Wowza Streaming Engine, SWAG and Portainer.

Do you want to delete this installer script?" 16 78; then
  rm $SCRIPT_DIR/DockerEngineInstaller.sh
fi