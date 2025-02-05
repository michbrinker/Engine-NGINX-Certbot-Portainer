####
# Function to convert uploaded jks file to pem
convert_jks_to_pem() {

echo "Converting $jks_file to crt and key format for use with Webserver and Portainer..."

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

# Convert PKCS12 to CRT (certificate only)
sudo openssl pkcs12 -in keystore.p12 -nokeys -out default.crt -passin pass:$jks_password

# Convert PKCS12 to KEY (private key only)
sudo openssl pkcs12 -in keystore.p12 -nodes -nocerts -out default.key -passin pass:$jks_password

# Copy files to an ssl dir
sudo mkdir $container_dir/certbot/letsencrypt/$jks_domain/
sudo cp default.crt $container_dir/certbot/letsencrypt/$jks_domain/default.crt && sudo cp default.key $container_dir/certbot/letsencrypt/$jks_domain/default.key
sudo chmod 644 $container_dir/certbot/letsencrypt/$jks_domain/default.crt && sudo chmod 644 $container_dir/certbot/letsencrypt/$jks_domain/default.key
}