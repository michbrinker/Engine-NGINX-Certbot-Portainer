#!/bin/bash

####
# Function to upload .jks file
upload_jks() {
  uploaded_jks=false
  while true; do
    if whiptail --title "SSL Configuration" --msgbox "Press [Enter] to continue after uploading the .jks file to $upload..." 10 60; then

      # Find all .jks files
      jks_files=($(ls "$upload"/*.jks 2>/dev/null))
      if [ ${#jks_files[@]} -eq 0 ]; then
        if whiptail --title "SSL Configuration" --yesno "No .jks file found. Would you like to upload again?" 10 60; then
          continue
        else
          whiptail --title "SSL Configuration" --msgbox "You chose not to add a .jks file. Continuing without SSL." 10 60
          use_ssl=false
          duckdns=false
          uploaded_jks=false
          chosen_jks_file=false
          create_docker_images          
          return 1
        fi
      else
        if [ ${#jks_files[@]} -eq 1 ]; then
          jks_file="${jks_files[0]}"
          whiptail --title "SSL Configuration" --msgbox "Found JKS file: $(basename "$jks_file")" 10 60 
        else
          # Create a radiolist with the list of .jks files
          menu_options=()
          for file in "${jks_files[@]}"; do
            menu_options+=("$(basename "$file")" "" OFF)
          done

          while true; do
            jks_file=$(whiptail --title "SSL Configuration" --radiolist "Multiple JKS files found. Choose one:" 20 60 10 "${menu_options[@]}" 3>&1 1>&2 2>&3)
            
            if [ $? -eq 0 ] && [ -n "$jks_file" ]; then
              break
            else
              if ! whiptail --title "SSL Configuration" --yesno "You must select a JKS file. Do you want to try again? Use the space button to select." 10 60; then
                whiptail --title "SSL Configuration" --msgbox "No JKS file selected. Exiting." 10 60
                use_ssl=false
                duckdns=false
                uploaded_jks=false
                chosen_jks_file=false
                create_docker_images
                return 1
              fi
            fi
          done

          if [ $? -ne 0 ]; then
            whiptail --title "SSL Configuration" --msgbox "You chose not to add a .jks file. Continuing without SSL." 10 60
            use_ssl=false
            duckdns=false
            uploaded_jks=false
            chosen_jks_file=false
            create_docker_images
            return 1
          fi
        fi
        chosen_jks_file=false
        duckdns=false
        uploaded_jks=true
        ssl_config "$jks_file"
        return 0
      fi
    else
      whiptail --title "SSL Configuration" --msgbox "You chose not to add a .jks file. Continuing without SSL" 10 60
      use_ssl=false
      duckdns=false
      uploaded_jks=false
      chosen_jks_file=false
      create_docker_images
      return 1
    fi
  done
}