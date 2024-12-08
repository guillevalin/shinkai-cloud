#!/bin/bash

# Default versions if not set in environment
OLLAMA_VERSION=${OLLAMA_VERSION:-"v0.5.1"}

# Create directory for binaries
INSTALL_DIR="/opt/ollama"
sudo mkdir -p $INSTALL_DIR
sudo mkdir -p $INSTALL_DIR/models

# Install dependencies
sudo apt-get update
sudo apt-get install -y curl tar openssl ca-certificates

# Download and setup Ollama
echo "Downloading Ollama ${OLLAMA_VERSION}..."
curl -L -o /tmp/ollama-linux-amd64.tgz "https://github.com/ollama/ollama/releases/download/${OLLAMA_VERSION}/ollama-linux-amd64.tgz"

# Verify Ollama download size
if [ $(stat -c %s /tmp/ollama-linux-amd64.tgz) -lt 26214400 ]; then
    echo "Error: ollama file is less than 25MB"
    exit 1
fi

# Extract Ollama
cd /tmp
tar -xvzf ollama-linux-amd64.tgz
sudo mv bin/ollama $INSTALL_DIR/
sudo chmod +x $INSTALL_DIR/ollama

# Create systemd service for Ollama
cat << EOF | sudo tee /etc/systemd/system/ollama.service
[Unit]
Description=Ollama Service
After=network.target

[Service]
ExecStart=$INSTALL_DIR/ollama serve
Environment=OLLAMA_HOST=0.0.0.0
Environment=OLLAMA_MODELS_DIR=$INSTALL_DIR/models
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start services
sudo systemctl daemon-reload
sudo systemctl enable ollama.service
sudo systemctl start ollama.service

# Pre-download models
sleep 10  # Wait for service to start
sudo $INSTALL_DIR/ollama pull llama3.1:8b-instruct-q4_1
sudo $INSTALL_DIR/ollama pull snowflake-arctic-embed:xs

echo "Installation complete. Ollama should start automatically on boot."