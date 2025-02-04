####
# Function to create HTML instructions
create_html_instructions() {

    # Get public IP with retry
    for i in {1..3}; do
        public_ip=$(curl -s -f https://api.ipify.org)
        [[ $? -eq 0 && -n "$public_ip" ]] && break
        sleep 2
    done

  # Create HTML instructions
  if $use_ssl; then
  cat <<EOL > "$container_dir/nginx/www/instructions.html"
<!DOCTYPE html>
<html>
<head>
  <title>WSE SWAG Portainer in Docker</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f9f9f9;
      color: #333;
      margin: 0;
      padding: 0;
    }
    header {
      background-color: #ff6600;
      color: white;
      padding: 20px;
      text-align: center;
    }
    .container {
      padding: 20px;
    }
    h1 {
      color: #f9f9f9;
    }    
    h2 {
      color: #ff6600;
    }
    p, ul {
      font-size: 16px;
      line-height: 1.6;
    }
    a {
      color: #ff6600;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    .logo {
      width: 50px;
      vertical-align: middle;
      margin-right: 10px;
    }
    .section {
      margin-bottom: 40px;
    }
  </style>
</head>
<body>
  <header>
    <h1>Wowza Streaming Engine, SWAG and Portainer in Docker</h1>
  </header>
  <div class="container">
    <div class="section">
      <h2>Wowza Streaming Engine</h2>
      <img src="https://www.wowza.com/wp-content/uploads/Wowza-logo-transparent.png" alt="Wowza Logo" class="logo">
      <p>Access the Wowza Streaming Engine Manager at: <a href="https://$jks_domain:8090" target="_blank">https://$jks_domain:8090</a></p>
      <p>Access the Swagger UI for REST API at: <a href="http://$public_ip/swagger/" target="_blank">http://$public_ip/swagger</a></p>
      <p>To manage the Engine files, use the following symlinks in the <strong>$container_dir</strong> directory:</p>
      <ul>
        <li>Engine_lib</li>
        <li>Engine_conf</li>
        <li>Engine_logs</li>
        <li>Engine_content</li>
        <li>Engine_transcoder</li>
        <li>Engine_manager</li>
      </ul>
      <p>Use the commands below to edit files directly, copy files in and out of the container:</p>
      <ul>
        <li>Edit files directly: <code>sudo nano Engine_xxxx/[file_name]</code></li>
        <li>Copy files out: <code>sudo cp Engine_xxxx/[file_name] [file_name]</code></li>
        <li>Copy files in: <code>sudo cp [file_name] Engine_xxxx/[file_name]</code></li>
      </ul>
      <p>NOTE: Container must be restarted for changes to take effect: <code>cd $container_dir && sudo docker restart $container_name && cd $SCRIPT_DIR</code></p>
      <p>To restart other containders, use ${container_name}_swag or ${container_name}_portainer in the same command</p>
      <p>To manage the state of the docker containers, use the following commands:</p>
      <ul>
        <li>Stop and destroy the Docker Wowza, swag and portainer container stack: <code>cd $container_dir && sudo docker compose down --rmi 'all' && cd $SCRIPT_DIR</code></li>
        <li>Stop the container stack without destroying it: <code>cd $container_dir && sudo docker compose stop && cd $SCRIPT_DIR</code></li>
        <li>Start the container stack after stopping it: <code>cd $container_dir && sudo docker compose start && cd $SCRIPT_DIR</code></li>
        <li>Restart the container stack: <code>cd $container_dir && sudo docker compose restart && cd $SCRIPT_DIR</code></li>
      </ul>
      <p>To delete volumes, use the following command:</p>
      <ul>
        <li><code>sudo docker volume ls</code></li>
        <li><code>sudo docker volume rm "volume name"</code></li>
      </ul>
      <p>To access the container directly, type: 
      <ul>
        <li><code>sudo docker exec -it $container_name bash</code></li>
      </ul>
    </div>

    <div class="section">
      <h2>Portainer</h2>
      <img src="https://w7.pngwing.com/pngs/112/58/png-transparent-portainer-wordmark-hd-logo.png" alt="Portainer Logo" class="logo">
      <p>Access the Portainer web interface at: <a href="https://$jks_domain:9443" target="_blank">https://$jks_domain:9443</a></p>
      <p>Portainer is a lightweight docker management UI that allows you to easily manage your Docker containers, images, networks, and volumes.</p>
      <p>For more information, visit the <a href="https://www.portainer.io" target="_blank">Portainer website</a>.</p>
    </div>

<div class="section">
       <h2>nginx</h2>
      <img src="https://banner2.cleanpng.com/20180630/hwg/aaymrz7q3.webp" alt="nginx Logo" class="logo">
      <p>Access the Nginx webserver at: <a href="https://$jks_domain:444" target="_blank">https://$jks_domain:444</a></p>
      <p>Nginx is a popular open-source web server software used to serve web content over the internet. It enables you to serve a player page, test SecureToken and aes128 encryption</p>
      <p>To manage the webserver and pages you can access the files in <strong>$container_dir/www</strong></p>
      <p>For more information, visit the <a href="https://nginx.org/en/" target="_blank">Nginx home page</a>.</p>
    </div>
  </div>
</body>
</html>
EOL
  else
  cat <<EOL > "$container_dir/nginx/www/instructions.html"
<!DOCTYPE html>
<html>
<head>
  <title>WSE SWAG Portainer in Docker</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f9f9f9;
      color: #333;
      margin: 0;
      padding: 0;
    }
    header {
      background-color: #ff6600;
      color: white;
      padding: 20px;
      text-align: center;
    }
    .container {
      padding: 20px;
    }
    h1 {
      color: #f9f9f9;
    }    
    h2 {
      color: #ff6600;
    }
    p, ul {
      font-size: 16px;
      line-height: 1.6;
    }
    a {
      color: #ff6600;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    .logo {
      width: 50px;
      vertical-align: middle;
      margin-right: 10px;
    }
    .section {
      margin-bottom: 40px;
    }
  </style>
</head>
<body>
  <header>
    <h1>Wowza Streaming Engine, SWAG and Portainer in Docker</h1>
  </header>
  <div class="container">
    <div class="section">
      <h2>Wowza Streaming Engine</h2>
      <img src="https://www.wowza.com/wp-content/uploads/Wowza-logo-transparent.png" alt="Wowza Logo" class="logo">
      <p>Access the Wowza Streaming Engine Manager at: <a href="http://$public_ip:8088" target="_blank">http://$public_ip:8088</a></p>
      <p>Access the Swagger UI for REST API at: <a href="http://$public_ip/swagger/" target="_blank">http://$public_ip/swagger</a></p>
      <p>To manage the Engine files, use the following symlinks in the <strong>$container_dir</strong> directory:</p>
      <ul>
        <li>Engine_lib</li>
        <li>Engine_conf</li>
        <li>Engine_logs</li>
        <li>Engine_content</li>
        <li>Engine_transcoder</li>
        <li>Engine_manager</li>
      </ul>
      <p>Use the commands below to edit files directly, copy files in and out of the container:</p>
      <ul>
        <li>Edit files directly: <code>sudo nano Engine_xxxx/[file_name]</code></li>
        <li>Copy files out: <code>sudo cp Engine_xxxx/[file_name] [file_name]</code></li>
        <li>Copy files in: <code>sudo cp [file_name] Engine_xxxx/[file_name]</code></li>
      </ul>
      <p>NOTE: Container must be restarted for changes to take effect: <code>cd $container_dir && sudo docker restart $container_name && cd $SCRIPT_DIR</code></p>
      <p>To restart other containders, use ${container_name}_swag or ${container_name}_portainer in the same command</p>
      <p>To manage the state of the docker containers, use the following commands:</p>
      <ul>
        <li>Stop and destroy the Docker Wowza, swag and portainer container stack: <code>cd $container_dir && sudo docker compose down --rmi 'all' && cd $SCRIPT_DIR</code></li>
        <li>Stop the container stack without destroying it: <code>cd $container_dir && sudo docker compose stop && cd $SCRIPT_DIR</code></li>
        <li>Start the container stack after stopping it: <code>cd $container_dir && sudo docker compose start && cd $SCRIPT_DIR</code></li>
        <li>Restart the container stack: <code>cd $container_dir && sudo docker compose restart && cd $SCRIPT_DIR</code></li>
      </ul>
      <p>To delete volumes, use the following command:</p>
      <ul>
        <li><code>sudo docker volume ls</code></li>
        <li><code>sudo docker volume rm "volume name"</code></li>
      </ul>
      <p>To access the container directly, type:
      <ul>
        <li><code>sudo docker exec -it $container_name bash</code></li>
      </ul>
      <p>To nuke the whole thing and start over, use the following commands:</p>
      <ul>
        <li>sudo docker system prune</li>
      </ul>
    </div>

    <div class="section">
      <h2>Portainer</h2>
      <img src="https://w7.pngwing.com/pngs/112/58/png-transparent-portainer-wordmark-hd-logo.png" alt="Portainer Logo" class="logo">
      <p>Access the Portainer web interface at: <a href="http://$public_ip:8000" target="_blank">http://$public_ip:8000</a></p>
      <p>Portainer is a lightweight docker management UI that allows you to easily manage your Docker containers, images, networks, and volumes.</p>
      <p>For more information, visit the <a href="https://www.portainer.io" target="_blank">Portainer website</a>.</p>
    </div>

    <div class="section">
       <h2>nginx</h2>
      <img src="https://banner2.cleanpng.com/20180630/hwg/aaymrz7q3.webp" alt="nginx Logo" class="logo">
      <p>Access the Nginx webserver at: <a href="http://$public_ip" target="_blank">http://$public_ip</a></p>
      <p>Nginx is a popular open-source web server software used to serve web content over the internet. It enables you to serve a player page, test SecureToken and aes128 encryption</p>
      <p>To manage the webserver and pages you can access the files in <strong>$container_dir/www</strong></p>
      <p>For more information, visit the <a href="https://nginx.org/en/" target="_blank">Nginx home page</a>.</p>
    </div>
  </div>
</body>
</html>
EOL
  fi
}