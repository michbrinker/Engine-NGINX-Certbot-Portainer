#!/bin/bash

# Function to check if another Docker Compose stack is currently running
check_running_stacks() {
  # Get a list of running Docker Compose stacks
  running_stacks=$(sudo docker ps --format '{{.Names}}' | grep -E '_nginx|_wowza|_portainer|_certbot')

  if [ -n "$running_stacks" ]; then
    whiptail --title "Running Docker Compose Stacks" --msgbox "The following Docker Compose stacks are currently running and will prevent proper installation:\n\n$running_stacks" 15 60

    if whiptail --title "Stop Running Stacks" --yesno "Do you want to stop the running stacks?" 10 60; then
      # Get unique Docker Compose project names
      compose_projects=$(sudo docker ps --format '{{.Label "com.docker.compose.project"}}' | sort | uniq | grep -v '^$')
      
      for project in $compose_projects; do
        # Find the directory where the docker-compose file is located
        project_dir=$(sudo docker ps --filter "label=com.docker.compose.project=$project" --format '{{.Label "com.docker.compose.project.working_dir"}}' | head -1)
        
        if [ -n "$project_dir" ] && [ -d "$project_dir" ]; then
          echo "Stopping Docker Compose project $project in directory $project_dir"
          # Navigate to the directory and run docker compose stop
          (cd "$project_dir" && sudo docker compose stop) || echo "Failed to stop project $project"
        fi
      done
      whiptail --title "Stacks Stopped" --msgbox "The running stacks have been stopped." 10 60
    else
      whiptail --title "Installation Cancelled" --msgbox "The installation has been cancelled." 10 60
      exit 1
    fi
  fi
  # No else block - function runs silently if no stacks are found
}