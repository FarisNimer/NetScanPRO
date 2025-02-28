# Use Ubuntu as the base image
FROM ubuntu:20.04

# Prevent prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory for Flask app
WORKDIR /app

# Install required dependencies
RUN apt-get update && apt-get install -y \
    tini \
    git \
    python3 \
    python3-pip \
    nmap \
    xterm \
    proxychains \
    socat \
    nginx \
    unzip \
    openssl \
    openssh-client \
    ca-certificates \
    wget \
    build-essential && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    mkdir -p /run/nginx && \
    echo "server { listen 80 default_server; root /var/www/html; location / { try_files \$uri /index.html; } }" > /etc/nginx/sites-available/default && \
    ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \
    echo "<html><head><title>Welcome to Nginx</title></head><body><h1>Nginx works!</h1></body></html>" > /var/www/html/index.html && \
    chown -R www-data:www-data /var/www/html && \
# Download, install and configure ngrok
    git clone --recursive https://github.com/trimstray/sandmap && \
    cd sandmap && \
    chmod +x setup.sh && \
    ./setup.sh install && \
    cd .. && \
    chmod +x /usr/local/bin/sandmap && \
    wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && \
    unzip ngrok-stable-linux-amd64.zip && \
    mv ngrok /usr/local/bin/ngrok && \
    rm ngrok-stable-linux-amd64.zip && \
    echo "web_addr: 0.0.0.0:4040" > /root/ngrok.yml && \
# Install ttyd from GitHub releases
    wget -q https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64 && \
    mv ttyd.x86_64 /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd && \
# Configure a nice terminal
    echo "export PS1='\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '" >> /etc/bash.bashrc && \
# Fake poweroff (stops the container from the inside by sending SIGTERM to PID 1)
    echo "alias poweroff='kill 1'" >> /etc/bash.bashrc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Flask and copy Flask app
COPY app.py /app/
RUN pip3 install flask

# Create a non-root user and set permissions
RUN useradd -m flaskuser && \
    chown -R flaskuser:flaskuser /app

# Expose the required ports
EXPOSE 7681 4040 80 5000

# Use tini to manage processes
ENTRYPOINT ["/usr/bin/tini", "--"]

# Run both Flask, ttyd, and automatically open Sandmap
CMD ["/bin/bash", "-c", "python3 app.py & ttyd -s 3 -t titleFixed=/bin/bash -t rendererType=webgl -t disableLeaveAlert=true /bin/bash -c 'sandmap' -i -l"]
