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
CREDENTIALS_URL="https://raw.githubusercontent.com/chpalex/DockerEngineInstaller/refs/heads/main/prompt_credentials.sh"
COMPOSE_URL="https://raw.githubusercontent.com/chpalex/DockerEngineInstaller/refs/heads/main/create_and_run_docker_compose.sh"
CONVERT_JKS_TO_PEM_URL=
CONVERT_PEM_TO_JKS_URK=
SWAGGER=
CLEANUP_URL="https://raw.githubusercontent.com/chpalex/DockerEngineInstaller/refs/heads/main/cleanup.sh"
CREATE_HTML_INSTRUCTIONS_URL=

# Download the Functions Scripts
curl -o "$SCRIPT_DIR/dependencies.sh" "$DEPENDENCIES_SCRIPT_URL" > /dev/null 2>&1
curl -o "$SCRIPT_DIR/fetch_and_set_wowza_versions.sh" "$FETCH_VERSIONS_SCRIPT_URL" > /dev/null 2>&1
curl -o "$SCRIPT_DIR/jks_functions.sh" "$JKS_FUNCTIONS_SCRIPT_URL" > /dev/null 2>&1
curl -o "$SCRIPT_DIR/tuning.sh" "$TUNING_SCRIPT_URL" > /dev/null 2>&1
curl -o "$SCRIPT_DIR/create_docker_image.sh" "$CREATE_DOCKER_IMAGE_SCRIPT_URL" > /dev/null 2>&1
curl -o "$SCRIPT_DIR/prompt_credentials.sh" "$PROMPT_CREDENTIALS_SCRIPT_URL" > /dev/null 2>&1
curl -o "$SCRIPT_DIR/create_and_run_docker_compose.sh" "$CREATE_AND_RUN_DOCKER_COMPOSE_SCRIPT_URL" > /dev/null 2>&1
curl -o "$SCRIPT_DIR/engine_file_fetch.sh" "$ENGINE_FILE_FETCH_SCRIPT_URL" > /dev/null 2>&1
curl -o "$SCRIPT_DIR/cleanup.sh" "$CLEANUP_SCRIPT_URL" > /dev/null 2>&1

# Source for the Functions Scripts
source "$SCRIPT_DIR/dependencies.sh"
source "$SCRIPT_DIR/fetch_and_set_wowza_versions.sh"
source "$SCRIPT_DIR/jks_functions.sh"
source "$SCRIPT_DIR/tuning.sh"
source "$SCRIPT_DIR/create_docker_image.sh"
source "$SCRIPT_DIR/prompt_credentials.sh"
source "$SCRIPT_DIR/create_and_run_docker_compose.sh"
source "$SCRIPT_DIR/engine_file_fetch.sh"
source "$SCRIPT_DIR/cleanup.sh"

dependencies
fetch_and_set_wowza_versions
if [ $? -ne 0 ]; then
  echo -e "${w}Installation cancelled by user."
  exit 1
fi
check_for_jks # runs upload_jks, ssl_config, duckDNS_create
create_docker_images
check_env_prompt_credentials 
create_and_run_docker_compose

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

install_swagger
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