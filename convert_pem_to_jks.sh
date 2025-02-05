# Function to convert PEM to PKCS12 and then to JKS
convert_pem_to_jks() {
  echo "Converting Letsencrypt certificate to JKS format ($jks_duckdns_domain.jks) for use with Wowza Streaming Engine..."
    local domain=$1
    local pem_dir=$container_dir/certbot/letsencrypt/archive/$domain
    local jks_dir=/usr/local/WowzaStreamingEngine/conf
    local pkcs12_password=$2
    local jks_password=$3

    # Check if required files are present
    required_files=("cert1.pem" "privkey1.pem" "chain1.pem" "fullchain1.pem")
    timeout=120  # Timeout in seconds
    start_time=$(date +%s)
    total_files=${#required_files[@]}
    files_found=0

   # Check if required files are present inside the Docker container
    required_files=("cert1.pem" "privkey1.pem" "chain1.pem" "fullchain1.pem")
    timeout=120  # Timeout in seconds
    start_time=$(date +%s)
    total_files=${#required_files[@]}
    files_found=0

    echo "Checking for required files..."

    while true; do
        all_files_present=true
        files_found=0
        for file in "${required_files[@]}"; do
            if test -f "$pem_dir/$file"; then
                files_found=$((files_found + 1))
            else
                all_files_present=false
            fi
        done

        if $all_files_present; then
            echo -ne "\rRequired files found"
            break
        fi

        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ $elapsed_time -ge $timeout ]; then
            echo -ne "\rError: Required files not found within the timeout period"
            return 1
        fi

        # Update echo timer on the same line
        echo -ne "\rElapsed time: $elapsed_time seconds. Files found: $files_found/$total_files"
        sleep 1  # Wait for 1 second before checking again
    done
    
    # Convert PEM to PKCS12 and then to JKS inside the Docker container
    sudo openssl pkcs12 -export -in "$pem_dir/cert1.pem" -inkey "$pem_dir/privkey1.pem" -out "$pem_dir/$domain.p12" -name "$domain" -passout pass:$pkcs12_password
    sudo docker cp $pem_dir/$domain.p12 $container_name:$jks_dir/$domain.p12
    sudo docker exec -it $container_name bash -c "   
        /usr/local/WowzaStreamingEngine/java/bin/keytool -importkeystore -srckeystore '$jks_dir/$domain.p12' -srcstoretype PKCS12 -srcstorepass $pkcs12_password -destkeystore '$jks_dir/$domain.jks' -deststorepass $jks_password -destkeypass $jks_password -alias '$domain' -noprompt &&
        /usr/local/WowzaStreamingEngine/java/bin/keytool -import -alias root -trustcacerts -file $jks_dir/ssl/archive/$domain/chain1.pem -keystore $domain.jks -storepass $jks_password &&
        /usr/local/WowzaStreamingEngine/java/bin/keytool -import -alias chain -trustcacerts -file $jks_dir/ssl/archive/$domain/fullchain1.pem -keystore $domain.jks -storepass $jks_password
    "

    if [ $? -eq 0 ]; then
        echo "Successfully converted PEM to JKS"
    else
        echo "Error: Failed to convert PEM to JKS. Please check the $container_dir/certbot/log/letsencryptletsencrypt.log file for more information"
        return 1
    fi

    return 0
}
openssl pkcs12 -export -in /usr/local/WowzaStreamingEngine/conf/ssl/archive/wowlex.duckdns.org/cert1.pem -inkey /usr/local/WowzaStreamingEngine/conf/ssl/archive/wowlex.duckdns.org/privkey1.pem -out /usr/local/WowzaStreamingEngine/conf/wowlex.duckdns.org.p12 -name wowlex.duckdns.org -passout pass:djuum20
/usr/local/WowzaStreamingEngine/java/bin/keytool -importkeystore -srckeystore /usr/local/WowzaStreamingEngine/conf/wowlex.duckdns.org.p12 -srcstoretype PKCS12 -srcstorepass djuum20 -destkeystore /usr/local/WowzaStreamingEngine/conf/wowlex.duckdns.org.jks -deststorepass djuum20 -destkeypass djuum20 -alias wowlex.duckdns.org -noprompt
/usr/local/WowzaStreamingEngine/java/bin/keytool -import -alias root -trustcacerts -file ssl/archive/wowlex.duckdns.org/chain1.pem -keystore wowlex.duckdns.org.jks -storepass djuum20
/usr/local/WowzaStreamingEngine/java/bin/keytool -import -alias chain -trustcacerts -file ssl/archive/wowlex.duckdns.org/fullchain1.pem -keystore wowlex.duckdns.org.jks -storepass djuum20 -noprompt
