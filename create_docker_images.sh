####
# Function to create Dockerfiles Wowza Engine and NGINX
create_docker_images() {
  # Create dockerfile for Wowza Engine
  # Change directory to wowza
  mkdir -p -m 777 "$encp/$container_dir/wowza" && cd "$encp/$container_dir/wowza"
  
  # Create a Dockerfile for WSE
  cat <<EOL > Dockerfile
FROM wowzamedia/wowza-streaming-engine-linux:${engine_version}

RUN apt update && apt install -y nano
WORKDIR /usr/local/WowzaStreamingEngine/
RUN ls -la /sbin/

# Create the tuning.sh script
RUN cat <<'EOF' > tuning.sh
#!/bin/bash

# Change ReceiveBufferSize and SendBufferSize values to 0 for <NetConnections> and <MediaCasters>
sed -i "s|<ReceiveBufferSize>.*</ReceiveBufferSize>|<ReceiveBufferSize>0</ReceiveBufferSize>|g" "/usr/local/WowzaStreamingEngine/conf/VHost.xml"
sed -i "s|<SendBufferSize>.*</SendBufferSize>|<SendBufferSize>0</SendBufferSize>|g" "/usr/local/WowzaStreamingEngine/conf/VHost.xml"

# Check CPU thread count
cpu_thread_count=\$(nproc)

# Calculate pool sizes with limits
handler_pool_size=\$((cpu_thread_count * 60))
transport_pool_size=\$((cpu_thread_count * 40))

# Apply limits
if [ "\$handler_pool_size" -gt 4096 ]; then
  handler_pool_size=4096
fi

if [ "\$transport_pool_size" -gt 4096 ]; then
  transport_pool_size=4096
fi

# Update Server.xml with new pool sizes
sed -i "s|<HandlerThreadPool>.*</HandlerThreadPool>|<HandlerThreadPool><PoolSize>\$handler_pool_size</PoolSize></HandlerThreadPool>|" "/usr/local/WowzaStreamingEngine/conf/Server.xml"
sed -i "s|<TransportThreadPool>.*</TransportThreadPool>|<TransportThreadPool><PoolSize>\$transport_pool_size</PoolSize></TransportThreadPool>|" "/usr/local/WowzaStreamingEngine/conf/Server.xml"

# Configure Demo live stream
sed -i "/<\/ServerListeners>/i \
          <ServerListener>\
            <BaseClass>com.wowza.wms.module.ServerListenerStreamDemoPublisher</BaseClass>\
          </ServerListener>" "/usr/local/WowzaStreamingEngine/conf/Server.xml"

# Find the line number of the closing </Properties> tag directly above the closing </Server> tag
line_number=\$(sed -n '/<\/Properties>/=' "/usr/local/WowzaStreamingEngine/conf/Server.xml" | tail -1)

# Insert the new property at the found line number
if [ -n "\$line_number" ]; then
  sed -i "\${line_number}i <Property>\
<Name>streamDemoPublisherConfig</Name>\
<Value>appName=live,srcStream=sample.mp4,dstStream=myStream,sendOnMetadata=true</Value>\
<Type>String</Type>\
</Property>" "/usr/local/WowzaStreamingEngine/conf/Server.xml"
fi

# Edit log4j2-config.xml to comment out serverError appender
sed -i "s|<AppenderRef ref=\"serverError\" level=\"warn\"/>|<!-- <AppenderRef ref=\"serverError\" level=\"warn\"/> -->|g" "/usr/local/WowzaStreamingEngine/conf/log4j2-config.xml"

EOF

RUN chmod +x tuning.sh
RUN ./tuning.sh
RUN rm tuning.sh

EOL

  if [ -f "$upload/tomcat.properties" ]; then
    echo "COPY upload/tomcat.properties /usr/local/WowzaStreamingEngine/manager/conf/" >> Dockerfile
    echo "RUN chown wowza:wowza /usr/local/WowzaStreamingEngine/manager/conf/tomcat.properties" >> Dockerfile

    # Change the <Port> line to have only 1935,554 ports
    echo "RUN sed -i 's|<Port>1935,80,443,554</Port>|<Port>1935,554</Port>|' /usr/local/WowzaStreamingEngine/conf/VHost.xml" >> Dockerfile

    # Edit the VHost.xml file to include the new HostPort block with the JKS and password information
    echo "RUN sed -i '/<\/HostPortList>/i \
    <HostPort>\n\  
        <Name>Autoconfig SSL Streaming</Name>\n\  
        <Type>Streaming</Type>\n\  
        <ProcessorCount>\${com.wowza.wms.TuningAuto}</ProcessorCount>\n\  
        <IpAddress>*</IpAddress>\n\  
        <Port>443</Port>\n\  
        <HTTPIdent2Response></HTTPIdent2Response>\n\  
        <SSLConfig>\n\  
            <KeyStorePath>/usr/local/WowzaStreamingEngine/conf/${jks_file}</KeyStorePath>\n\  
            <KeyStorePassword>${jks_password}</KeyStorePassword>\n\  
            <KeyStoreType>JKS</KeyStoreType>\n\  
            <DomainToKeyStoreMapPath></DomainToKeyStoreMapPath>\n\  
            <SSLProtocol>TLS</SSLProtocol>\n\  
            <Algorithm>SunX509</Algorithm>\n\  
            <CipherSuites></CipherSuites>\n\  
            <Protocols></Protocols>\n\  
            <AllowHttp2>true</AllowHttp2>\n\  
        </SSLConfig>\n\  
        <SocketConfiguration>\n\  
            <ReuseAddress>true</ReuseAddress>\n\  
            <ReceiveBufferSize>0</ReceiveBufferSize>\n\  
            <ReadBufferSize>65000</ReadBufferSize>\n\  
            <SendBufferSize>0</SendBufferSize>\n\  
            <KeepAlive>true</KeepAlive>\n\  
            <AcceptorBackLog>100</AcceptorBackLog>\n\  
        </SocketConfiguration>\n\  
        <HTTPStreamerAdapterIDs>cupertinostreaming,smoothstreaming,sanjosestreaming,dvrchunkstreaming,mpegdashstreaming</HTTPStreamerAdapterIDs>\n\  
        <HTTPProviders>\n\  
            <HTTPProvider>\n\  
                <BaseClass>com.wowza.wms.http.HTTPCrossdomain</BaseClass>\n\  
                <RequestFilters>*crossdomain.xml</RequestFilters>\n\  
                <AuthenticationMethod>none</AuthenticationMethod>\n\  
            </HTTPProvider>\n\  
            <HTTPProvider>\n\  
                <BaseClass>com.wowza.wms.http.HTTPClientAccessPolicy</BaseClass>\n\  
                <RequestFilters>*clientaccesspolicy.xml</RequestFilters>\n\  
                <AuthenticationMethod>none</AuthenticationMethod>\n\  
            </HTTPProvider>\n\  
            <HTTPProvider>\n\  
                <BaseClass>com.wowza.wms.http.HTTPProviderMediaList</BaseClass>\n\  
                <RequestFilters>*jwplayer.rss|*jwplayer.smil|*medialist.smil|*manifest-rtmp.f4m</RequestFilters>\n\  
                <AuthenticationMethod>none</AuthenticationMethod>\n\  
            </HTTPProvider>\n\  
            <HTTPProvider>\n\  
                <BaseClass>com.wowza.wms.webrtc.http.HTTPWebRTCExchangeSessionInfo</BaseClass>\n\  
                <RequestFilters>*webrtc-session.json</RequestFilters>\n\  
                <AuthenticationMethod>none</AuthenticationMethod>\n\  
            </HTTPProvider>\n\  
            <HTTPProvider>\n\  
                <BaseClass>com.wowza.wms.http.HTTPServerVersion</BaseClass>\n\  
                <RequestFilters>*ServerVersion</RequestFilters>\n\  
                <AuthenticationMethod>none</AuthenticationMethod>\n\  
            </HTTPProvider>\n\  
        </HTTPProviders>\n\  
    </HostPort>' /usr/local/WowzaStreamingEngine/conf/VHost.xml" >> Dockerfile

    # Edit the VHost.xml file to include the new TestPlayer block with the jks_domain
    echo "RUN sed -i '/<\/Manager>/i \
    <TestPlayer>\n\
        <IpAddress>${jks_domain}</IpAddress>\n\
        <Port>443</Port>\n\
        <SSLEnable>true</SSLEnable>\n\
    </TestPlayer>' /usr/local/WowzaStreamingEngine/conf/VHost.xml" >> Dockerfile

    # Edit the Server.xml file to include the JKS and password information
    echo "RUN sed -i 's|<Enable>false</Enable>|<Enable>true</Enable>|' /usr/local/WowzaStreamingEngine/conf/Server.xml" >> Dockerfile
    echo "RUN sed -i 's|<KeyStorePath></KeyStorePath>|<KeyStorePath>/usr/local/WowzaStreamingEngine/conf/${jks_file}</KeyStorePath>|' /usr/local/WowzaStreamingEngine/conf/Server.xml" >> Dockerfile
    echo "RUN sed -i 's|<KeyStorePassword></KeyStorePassword>|<KeyStorePassword>${jks_password}</KeyStorePassword>|' /usr/local/WowzaStreamingEngine/conf/Server.xml" >> Dockerfile
    echo "RUN sed -i 's|<IPWhiteList>127.0.0.1</IPWhiteList>|<IPWhiteList>*</IPWhiteList>|' /usr/local/WowzaStreamingEngine/conf/Server.xml" >> Dockerfile

    # Edit the Server.xml file to add swagger documentation access
    echo "RUN sed -i 's|<DocumentationServerEnable>false</DocumentationServerEnable>|<DocumentationServerEnable>true</DocumentationServerEnable>|' /usr/local/WowzaStreamingEngine/conf/Server.xml" >> Dockerfile
  fi

# Created dockerfile for NGINX
  # Change directory to nginx
  mkdir -p -m 777 "$encp/$container_dir/nginx" && cd "$encp/$container_dir/nginx"
  # Copy dependency files from github
  wget -P config/conf.d https://github.com/chpalex/Engine-nginx-Certbot-Portainer/blob/master/nginx/config/conf.d/default.conf
  wget -P config https://github.com/chpalex/Engine-nginx-Certbot-Portainer/blob/master/nginx/config/fpm-pool.conf
  wget -P config https://github.com/chpalex/Engine-nginx-Certbot-Portainer/blob/master/nginx/config/nginx.conf
  wget -P config https://github.com/chpalex/Engine-nginx-Certbot-Portainer/blob/master/nginx/config/php.ini
  wget -P config https://github.com/chpalex/Engine-nginx-Certbot-Portainer/blob/master/nginx/config/supervisord.conf
  wget -P src https://github.com/chpalex/Engine-nginx-Certbot-Portainer/blob/master/nginx/src/index.php
  wget -P src https://github.com/chpalex/Engine-nginx-Certbot-Portainer/blob/master/nginx/src/test.html

    # Create a Dockerfile for WSE
  cat <<EOL > Dockerfile
FROM alpine:latest
LABEL Description="Lightweight container with Nginx 1.26 & PHP 8.4 based on Alpine Linux."
# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nano \
  nginx \
  php84 \
  php84-ctype \
  php84-curl \
  php84-dom \
  php84-fileinfo \
  php84-fpm \
  php84-gd \
  php84-intl \
  php84-mbstring \
  php84-mysqli \
  php84-opcache \
  php84-openssl \
  php84-phar \
  php84-session \
  php84-tokenizer \
  php84-xml \
  php84-xmlreader \
  php84-xmlwriter \
  supervisor

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
ENV PHP_INI_DIR=/etc/php84
COPY config/fpm-pool.conf ${PHP_INI_DIR}/php-fpm.d/www.conf
COPY config/php.ini ${PHP_INI_DIR}/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody:nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
COPY --chown=nobody src/ /var/www/html/

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping || exit 1
EOL
}
