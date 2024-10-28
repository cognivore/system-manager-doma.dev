server {

    ####################################################################################################################################
    # Proxy Headers                                                                                                                    #
    ####################################################################################################################################
    #                                                                                                                                  #
    #    proxy_set_header: These directives allow Nginx to pass important information about the client request to the proxied server.  #
    #    This includes the original host requested by the client, the client's IP address, and the protocol used for the request.      #
    #    This information can be crucial for applications that generate links, redirect, or perform security checks.                   #
    #                                                                                                                                  #
    ####################################################################################################################################
    # Security Headers                                                                                                                 #
    ####################################################################################################################################
    #                                                                                                                                  #
    #    X-Frame-Options: Protects your visitors against clickjacking attacks.                                                         #
    #    It tells the browser whether your content can be framed.                                                                      #
    #    SAMEORIGIN means your content can only be framed by the same site.                                                            #
    #                                                                                                                                  #
    #    X-Content-Type-Options: Prevents MIME type sniffing.                                                                          #
    #    It tells the browser to stick with the declared content-type.                                                                 #
    #    nosniff blocks requests if the type is a style/script and the MIME type is not text/css or application/javascript.            #
    #                                                                                                                                  #
    ####################################################################################################################################
    # Buffering and Timeouts                                                                                                           #
    ####################################################################################################################################
    #                                                                                                                                  #
    #    proxy_buffering, proxy_buffers: These directives control the buffering of responses from the proxied server.                  #
    #    Buffering can help improve performance by reading large chunks of data at a time and reducing the number of read operations.  #
    #                                                                                                                                  #
    #    client_body_buffer_size: This sets the size of the buffer used for reading the client request body.                           #
    #                                                                                                                                  #
    #    proxy_read_timeout, proxy_send_timeout:                                                                                       #
    #    These set the timeout values for reading a response from the proxied server and sending a response to the client.             #
    #    Setting this to a high value can be useful if the proxied server takes a long time to generate responses.                     #
    #    Alternatively, it can help slow clients. Setting it inadequately high can open a DoS vector with slowloris type of attack.    #
    #                                                                                                                                  #
    ####################################################################################################################################
    charset utf-8;
    client_max_body_size 512M;
    server_name staging.app.zerohr.io;

    location / {
	proxy_pass http://127.0.0.1:16427;
	# proxy_pass http://127.0.0.1:16426;
        # proxy_pass http://127.0.0.1:16425;
        # proxy_max_temp_file_size 0;

        # Set proxy headers for the upstream server to use
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # These headers help prevent security issues like clickjacking and content sniffing
        add_header X-Frame-Options SAMEORIGIN always;
        add_header X-Content-Type-Options nosniff always;

        # Enable buffer for reading response headers and the beginning of the response body from the proxied server
        proxy_buffering on;
        # proxy_buffers 32 4k;

        # Adjust the buffer size for the client request body (increase if users send large requests)
        # client_body_buffer_size 16k;

        # Define timeout values for the proxy to prevent long waiting times or premature timeouts
        # proxy_read_timeout 600s;
        # proxy_send_timeout 600s;
    }


    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/staging.app.zerohr.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/staging.app.zerohr.io/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = staging.app.zerohr.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot



    listen 80;
    server_name staging.app.zerohr.io;
    return 404; # managed by Certbot


}
