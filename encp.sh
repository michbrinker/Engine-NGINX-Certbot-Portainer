#!/bin/bash
# This script installs Docker, Wowza Streaming Engine, Nginx with PHP, Portainer, and Certbot on a Linux system.
curl https://raw.githubusercontent.com/chpalex/Engine-NGNIX-Certbot-Portainer/refs/heads/master/installer.sh -o DockerEngineInstaller.sh && chmod +x DockerEngineInstaller.sh && sudo ./DockerEngineInstaller.sh