#!/bin/bash

dependencies() {
####
# Function to install Docker
install_docker() {
  echo -e "${w}Checking if Docker is installed"
  if ! command -v docker &> /dev/null; then
  echo "   -----Docker not found, starting Docker installation-----"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  echo "   -----Docker Installation complete-----"
  else
  echo -e "${w}Docker found"
  fi
}

####
# Function to install jq
install_jq() {
  if ! command -v jq &> /dev/null; then
  echo "   -----jq not found, installing jq-----"
  sudo apt-get install -y jq > /dev/null 2>&1
  fi
}

####
# Function to install unzip
install_unzip() {
  if ! command -v unzip &> /dev/null; then
  echo "   -----unzip not found, installing unzip-----"
  sudo apt install -y unzip > /dev/null 2>&1
  fi
}

install_docker
install_jq
install_unzip
}