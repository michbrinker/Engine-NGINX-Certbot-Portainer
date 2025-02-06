#!/bin/bash

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
  <title>WSE Nginx Portainer in Docker</title>
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
    <h1>Wowza Streaming Engine, Nginx and Portainer in Docker</h1>
  </header>
  <div class="container">
    <div class="section">
      <h2>Wowza Streaming Engine</h2>
      <img src="https://www.wowza.com/wp-content/uploads/Wowza-logo-transparent.png" alt="Wowza Logo" class="logo">
      <p>Access the Wowza Streaming Engine Manager at: <a href="https://$jks_domain:8090" target="_blank">https://$jks_domain:8090</a></p>
      <p>Access the Swagger UI for REST API at: <a href="http://$public_ip/swagger/" target="_blank">http://$public_ip/swagger</a></p>
      <p>To manage the Engine files, navigate to <strong>$container_dir/WowzaStreamingEngine</strong> directory.</p>
      <p>NOTE: Container must be restarted for changes to take effect: <code>sudo docker restart $container_name</code></p>
      <p>To restart other containers, use <code>${container_name}_nginx</code> or <code>${container_name}_portainer</code> or <code>${container_name}_certbot</code> in the same command as above</p>
       
      <p>To manage the state of the docker stack, use the following commands:</p>
      <ul>
        <li>Stop and destroy the whole container stack:</li>
        <ul>
        <li><code>cd $container_dir && sudo docker compose down --rmi 'all' && cd $SCRIPT_DIR</code></li>
        </ul>
        <li>Stop the container stack without destroying it: </li>
        <ul>
        <li><code>cd $container_dir && sudo docker compose stop && cd $SCRIPT_DIR</code></li>
        </ul>
        <li>Start the container stack after stopping it: </li>
        <ul>
        <li><code>cd $container_dir && sudo docker compose start && cd $SCRIPT_DIR</code></li>
        </ul>
        <li>Restart the container stack:</li>
        <ul>
        <li><code>cd $container_dir && sudo docker compose restart && cd $SCRIPT_DIR</code></li>
        </ul>
      </ul>
      <p>To delete all unused volumes, use the following command:</p>
      <ul>
        <li><code>sudo docker volume prune</code></li>
      </ul>
      <p>To delete all unused containers, use the following command:</p>
      <ul>
        <li><code>sudo docker system prune</code></li>
      </ul>
      <p>To access the container directly via command line, type: 
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
  <title>WSE Nginx Portainer in Docker</title>
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
    <h1>Wowza Streaming Engine, Nginx and Portainer in Docker</h1>
  </header>
  <div class="container">
    <div class="section">
      <h2>Wowza Streaming Engine</h2>
      <img src="https://www.wowza.com/wp-content/uploads/Wowza-logo-transparent.png" alt="Wowza Logo" class="logo">
      <p>Access the Wowza Streaming Engine Manager at: <a href="http://$public_ip:8088" target="_blank">http://$public_ip:8088</a></p>
      <p>Access the Swagger UI for REST API at: <a href="http://$public_ip/swagger/" target="_blank">http://$public_ip/swagger</a></p>
      <p>To manage the Engine files, navigate to <strong>$container_dir/WowzaStreamingEngine</strong> directory.</p>
      <p>NOTE: Container must be restarted for changes to take effect: <code>sudo docker restart $container_name</code></p>
      <p>To restart other containers, use <code>${container_name}_nginx</code> or <code>${container_name}_portainer</code> or <code>${container_name}_certbot</code> in the same command as above</p>
      
      <p>To manage the state of the docker stack, use the following commands:</p>
      <ul>
        <li>Stop and destroy the whole container stack:</li>
        <ul>
        <li><code>cd $container_dir && sudo docker compose down --rmi 'all' && cd $SCRIPT_DIR</code></li>
        </ul>
        <li>Stop the container stack without destroying it: </li>
        <ul>
        <li><code>cd $container_dir && sudo docker compose stop && cd $SCRIPT_DIR</code></li>
        </ul>
        <li>Start the container stack after stopping it: </li>
        <ul>
        <li><code>cd $container_dir && sudo docker compose start && cd $SCRIPT_DIR</code></li>
        </ul>
        <li>Restart the container stack:</li>
        <ul>
        <li><code>cd $container_dir && sudo docker compose restart && cd $SCRIPT_DIR</code></li>
        </ul>
      </ul>
      <p>To delete all unused volumes, use the following command:</p>
      <ul>
        <li><code>sudo docker volume prune</code></li>
      </ul>
      <p>To delete all unused containers, use the following command:</p>
      <ul>
        <li><code>sudo docker system prune</code></li>
      </ul>
      <p>To access the container directly via command line, type: 
      <ul>
        <li><code>sudo docker exec -it $container_name bash</code></li>
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