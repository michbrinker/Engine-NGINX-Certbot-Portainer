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
whiptail --title "Engine Nginx Certbot Portainer (encp) Workflow Installer" --msgbox "
Welcome to the Docker Engine Workflow Installer!\n\nThis installation script automates the deployment of\n\n - Wowza Streaming Engine\n\n - Nginx (simple webserver)\n\n - Certbot (automatic SSL management)\n\n - Portainer (docker management tool)\n\nin a Docker stack." 20 75

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

echo "Getting a few things ready for the installation"

# URL of the Functions Scripts
DEPENDENCIES_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/dependencies.sh"
FETCH_AND_SET_WOWZA_VERSIONS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/fetch_and_set_wowza_versions.sh"
CHECK_FOR_JKS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/check_for_jks.sh"
UPLOAD_JKS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/upload_jks.sh"
DUCKDNS_CREATE_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/duckDNS_create.sh"
SSL_CONFIG_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/ssl_config.sh"
CREATE_DOCKER_IMAGES_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/create_docker_images.sh"
CREDENTIALS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/credentials.sh"
STOP_PREVIOUS_DOCKER_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/stop_previous_docker.sh"
COMPOSE_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/compose.sh"
CONVERT_JKS_TO_PEM_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/convert_jks_to_pem.sh"
CONVERT_PEM_TO_JKS_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/convert_pem_to_jks.sh"
SWAGGER="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/swagger.sh"
CLEANUP_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/cleanup.sh"
MOUNT_ENGINE_CONF_URL="https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/mount_engine_conf.sh"
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
curl -o "$encp/stop_previous_docker.sh" "$STOP_PREVIOUS_DOCKER_URL" > /dev/null 2>&1
curl -o "$encp/compose.sh" "$COMPOSE_URL" > /dev/null 2>&1
curl -o "$encp/convert_jks_to_pem.sh" "$CONVERT_JKS_TO_PEM_URL" > /dev/null 2>&1
curl -o "$encp/convert_pem_to_jks.sh" "$CONVERT_PEM_TO_JKS_URL" > /dev/null 2>&1
curl -o "$encp/swagger.sh" "$SWAGGER" > /dev/null 2>&1
curl -o "$encp/create_html_instructions.sh" "$CREATE_HTML_INSTRUCTIONS_URL" > /dev/null 2>&1
curl -o "$encp/mount_engine_conf.sh" "$MOUNT_ENGINE_CONF_URL" > /dev/null 2>&1 
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
source "$encp/stop_previous_docker.sh"
source "$encp/compose.sh"
source "$encp/convert_jks_to_pem.sh"
source "$encp/convert_pem_to_jks.sh"
source "$encp/swagger.sh"
source "$encp/create_html_instructions.sh"
source "$encp/mount_engine_conf.sh"
source "$encp/cleanup.sh"

dependencies
fetch_and_set_wowza_versions
if [ $? -ne 0 ]; then
  echo -e "${w}Installation cancelled by user."
  exit 1
fi
check_for_jks # runs upload_jks, ssl_config, duckDNS_create

if ! $duckdns && $use_ssl; then
  convert_jks_to_pem
fi

create_docker_images
credentials
compose

if $duckdns && $use_ssl; then
  convert_pem_to_jks "$jks_duckdns_domain" "$jks_password" "$jks_password"
fi

swagger
cleanup
create_html_instructions
mount_engine_conf

if $use_ssl; then
echo -e "${w}For instructions on using the installed software, please visit ${yellow}https://$jks_domain:444/instructions.html${NOCOLOR}"
else
echo -e "${w}For instructions on using the installed software, please open ${yellow}http://$public_ip/instructions.html${NOCOLOR}"
fi

# Prompt user to delete installer script
if whiptail --title "Installation complete" --yesno "The installer has completed the installation of 
Wowza Streaming Engine, Nginx, certbot and Portainer.

Do you want to delete this installer script?" 16 78; then
  rm $SCRIPT_DIR/DockerEngineInstaller.sh
fi