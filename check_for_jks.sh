####
# Function to check if SSL is going to be used, then scan for .jks file, offer to choose an available one
check_for_jks() {
    use_ssl=false
  # Step 1: Ask user if they want to use SSL
  if whiptail --title "SSL Configuration" --yesno "Do you want to use SSL? Note: The installer can assist in getting a free domain and SSL. Non SSL config is currently broken for Webserver" 10 60; then
    export use_ssl=true
  else
    export use_ssl=false
    export duckdns=false
    export uploaded_jks=false
    export chosen_jks_file=false
    create_docker_images
    return 1
  fi

  whiptail --title "SSL Configuration" --msgbox "Starting SSL Configuration... \nSearching for existing SSL Java Key Store (JKS) files in $upload" 10 60

  # Step 2: Find all .jks files
  jks_files=($(ls "$upload"/*.jks 2>/dev/null))
  export chosen_jks_file=false
  if [ ${#jks_files[@]} -eq 0 ]; then
    whiptail --title "SSL Configuration" --msgbox "No .jks file/s found." 10 60
    if whiptail --title "SSL Configuration" --yesno "Do you want to upload a JKS file or create a new domain and JKS file?" 10 60 --yes-button "Upload" --no-button "Create"; then
      upload_jks
    else
      duckDNS_create
    fi
  else
    if [ ${#jks_files[@]} -eq 1 ]; then
      jks_file="${jks_files[0]}"
      if whiptail --title "JKS File/s Detected" --yesno "A .jks file $(basename "$jks_file") was detected. Do you want to use this file?" 10 60; then
        export chosen_jks_file=true
        export uploaded_jks=false
        export duckdns=false
        ssl_config "$jks_file"
      else
        if whiptail --title "SSL Configuration" --yesno "Do you want to upload a JKS file or create a new domain and JKS file?" 10 60 --yes-button "Upload" --no-button "Create"; then
          upload_jks
        else
          duckDNS_create
        fi
      fi
    else
      # Create a radiolist with the list of .jks files
      menu_options=()
      for file in "${jks_files[@]}"; do
        menu_options+=("$(basename "$file")" "" OFF)
      done
      # Present a list of .jks files to choose from
      while true; do
        jks_file=$(whiptail --title "SSL Configuration" --radiolist "Multiple JKS files found. Choose one:" 20 60 10 "${menu_options[@]}" 3>&1 1>&2 2>&3)
        
        if [ $? -eq 0 ] && [ -n "$jks_file" ]; then
          export jks_file="$upload/$jks_file"
          break
        else
          if ! whiptail --title "SSL Configuration" --yesno "You must select a JKS file. Do you want to try again? Use the space button to select." 10 60; then
            whiptail --title "SSL Configuration" --msgbox "No JKS file selected. Exiting." 10 60
              export use_ssl=false
              export duckdns=false
              export uploaded_jks=false
              export chosen_jks_file=false
              create_docker_images
            return 1
          fi
        fi
      done
      export chosen_jks_file=true
      ssl_config "$jks_file"
    fi
  fi
}