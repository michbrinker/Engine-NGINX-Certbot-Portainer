####
# Function to convert uploaded jks file to pem
convert_jks_to_pem() {

echo "Converting $jks_file to PEM format for use with Webserver and Portainer..."

# Check if keytool is installed and install it
    if ! command -v keytool &> /dev/null; then
        echo "keytool could not be found. Installing..."
        sudo apt-get update
        sudo apt-get install -y openjdk-21-jre-headless
    fi
cd $upload
    # Convert JKS to PKCS12
    sudo keytool -importkeystore \
        -srckeystore "$jks_file" \
        -srcstorepass "$jks_password" \
        -srcstoretype JKS \
        -destkeystore keystore.p12 \
        -deststoretype PKCS12 \
        -deststorepass "$jks_password" \
        -destkeypass "$jks_password" \
        -noprompt

# Convert PKCS12 to PEM (certificate only)
sudo openssl pkcs12 -in keystore.p12 -nokeys -out fullchain.pem -passin pass:$jks_password

# Convert PKCS12 to PEM (private key only)
sudo openssl pkcs12 -in keystore.p12 -nodes -nocerts -out privkey.pem -passin pass:$jks_password

sudo cp fullchain.pem $container_dir/certbot/letsencrypt/$jks_domain && sudo cp privkey.pem $container_dir/certbot/letsencrypt/$jks_domain
}