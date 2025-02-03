####
# Function to guide DuckDNS domain setup and prep for swag SSL setup
duckDNS_create() {
    duckdns=false
    local readonly DIALOG_WIDTH=60
    local readonly DIALOG_HEIGHT=12
    local public_ip

    # Get public IP with retry
    for i in {1..3}; do
        public_ip=$(curl -s -f https://api.ipify.org)
        [[ $? -eq 0 && -n "$public_ip" ]] && break
        sleep 2
    done

    [[ -z "$public_ip" ]] && {
        whiptail --title "Error" --msgbox "Failed to get public IP" 8 $DIALOG_WIDTH
        return 1
    }

    # Show instructions for DuckDNS 
    whiptail --title "DuckDNS Setup" --msgbox "Please: \n\n1. Go to duckdns.org\n2. Create a new domain pointing to: $public_ip\n3. Copy your token\n\nClick OK when ready." $DIALOG_HEIGHT $DIALOG_WIDTH

    # Get domain that was configured in DuckDNS
    while true; do
        jks_duckdns_domain=$(whiptail --title "DuckDNS Domain" --inputbox "Enter your DuckDNS domain (without .duckdns.org):" 8 $DIALOG_WIDTH 3>&1 1>&2 2>&3)
        
        if [[ $? -ne 0 ]]; then
            whiptail --title "Error" --msgbox "Domain input was canceled. Exiting." 8 $DIALOG_WIDTH
              use_ssl=false
              duckdns=false
              uploaded_jks=false
              chosen_jks_file=false
              create_docker_image
            return 1
        elif [[ -z "$jks_duckdns_domain" ]]; then
            whiptail --title "Error" --msgbox "Domain input is required. Please enter a valid DuckDNS domain." 8 $DIALOG_WIDTH
        else
            break
        fi
    done

    # Get DuckDNS token
    while true; do
        duckdns_token=$(whiptail --title "DuckDNS Token" --inputbox "Enter your DuckDNS token:" 8 $DIALOG_WIDTH 3>&1 1>&2 2>&3)
        
        if [[ $? -ne 0 ]]; then
            whiptail --title "Error" --msgbox "Token input was canceled. Exiting." 8 $DIALOG_WIDTH
              use_ssl=false
              duckdns=false
              uploaded_jks=false
              chosen_jks_file=false
              create_docker_image
            return 1
        elif [[ -z "$duckdns_token" ]]; then
            whiptail --title "Error" --msgbox "DuckDNS token is required. Please enter a valid token." 8 $DIALOG_WIDTH
        else
            break
        fi
    done

    # Export variables and append domain
    export jks_duckdns_domain="${jks_duckdns_domain}.duckdns.org" duckdns_token

    # Create temp JKS file
    touch "$upload/${jks_duckdns_domain}.jks"
    # Create jksfile variable
    jks_file="$upload/${jks_duckdns_domain}.jks"

      # Create and copy duckdns.ini with secure permissions
        if printf "dns_duckdns_token=%s\n" "$duckdns_token" > "$container_dir/certbot/duckdns.ini"; then
            sudo chmod 644 "$container_dir/certbot/duckdns.ini" && chosen_jks_file=false && uploaded_jks=false && duckdns=true && ssl_config "$jks_file"
        else
            whiptail --title "Error" --msgbox "Failed to create DuckDNS configuration" 8 $DIALOG_WIDTH
              use_ssl=false
              duckdns=false
              uploaded_jks=false
              chosen_jks_file=false
              create_docker_image
            return 1
        fi
    return 0
}