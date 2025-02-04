####
# Function to install Swagger UI
swagger() {
  # Download Swagger UI from Wowza
  cd "$container_dir/nginx/www"
  wget https://www.wowza.com/downloads/forums/restapidocumentation/RESTAPIDocumentationWebpage.zip
  unzip -o RESTAPIDocumentationWebpage.zip -d swagger
  rm RESTAPIDocumentationWebpage.zip

  # Replace the URL in the swagger/index.html file
  if $use_ssl; then
  sed -i "s|http://localhost:8089/api-docs|https://$jks_domain:8089/api-docs|g" swagger/index.html
  else
  sed -i "s|http://localhost:8089/api-docs|http://$public_ip:8089/api-docs|g" swagger/index.html
  fi
}