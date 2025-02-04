#
#### Check for Engine credentials and create .env file
credentials () {

  prompt_credentials() {
  # Get user name, password and license key
  WSE_MGR_USER=$(whiptail --inputbox "Provide Wowza username:" 8 78 "$1" --title "Wowza Credentials" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ] || [ -z "$WSE_MGR_USER" ]; then
    whiptail --msgbox "Username is required. Please try again." 8 78 --title "Error"
    WSE_MGR_USER=$(whiptail --inputbox "Provide Wowza username:" 8 78 "$1" --title "Wowza Credentials" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$WSE_MGR_USER" ]; then
      echo "No username provided, exiting install process" >&2
      exit 1
    fi
  fi

  WSE_MGR_PASS=$(whiptail --passwordbox "Provide Wowza password:" 8 78 --title "Wowza Credentials" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ] || [ -z "$WSE_MGR_PASS" ]; then
    whiptail --msgbox "Password is required. Please try again." 8 78 --title "Error"
    WSE_MGR_PASS=$(whiptail --passwordbox "Provide Wowza password:" 8 78 --title "Wowza Credentials" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$WSE_MGR_PASS" ]; then
      echo "No password provided, exiting install process" >&2
      exit 1
    fi
  fi

  WSE_LIC=$(whiptail --inputbox "Provide Wowza license key:" 8 78 "$2" --title "Wowza License Key" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ] || [ -z "$WSE_LIC" ]; then
    whiptail --msgbox "License key is required. Please try again." 8 78 --title "Error"
    WSE_LIC=$(whiptail --inputbox "Provide Wowza license key:" 8 78 "$2" --title "Wowza License Key" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$WSE_LIC" ]; then
      echo "No license key provided, exiting install process" >&2
      exit 1
    fi
  fi

  if $duckdns; then
    SSL_EMAIL=$(whiptail --inputbox "Provide email address for SSL Certificate:" 8 78 --title "ZeroSSL Email" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ] || [ -z "$SSL_EMAIL" ]; then
    whiptail --msgbox "Email address required. Please try again." 8 78 --title "Error"
    SSL_EMAIL=$(whiptail --inputbox "Provide email address for SSL Certificate:" 8 78 --title "ZeroSSL Email" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$SSL_EMAIL" ]; then
      echo "No email provided, exiting install process" >&2
      exit 1
    fi
  fi
  fi
}

check_env_prompt_credentials() {
# Check if .env file exists
if [ -f $container_dir/.env ]; then
  # Read existing values from .env file
  source $container_dir/.env
  # Present a whiptail window with existing data allowing user to make changes
  prompt_credentials "$WSE_MGR_USER" "$WSE_LIC" "$EMAIL"
else
  # Prompt user for Wowza Streaming Engine Manager credentials and license key using whiptail
  prompt_credentials "" ""
fi

# Get local timezone
tz=$(timedatectl | grep "Time zone" | awk '{print $3}')

# Create .env file
cat <<EOL > "$container_dir/.env"
WSE_MGR_USER=${WSE_MGR_USER}
WSE_MGR_PASS=${WSE_MGR_PASS}
WSE_LIC=${WSE_LIC}
URL=${jks_domain}
EMAIL=${SSL_EMAIL}
EOL
}

check_env_prompt_credentials

}