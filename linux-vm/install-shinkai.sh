#!/bin/bash

# Default versions if not set in environment
SHINKAI_NODE_VERSION=${SHINKAI_NODE_VERSION:-"v0.8.16"}

# Create directory for binaries
INSTALL_DIR="/opt/shinkai"
sudo mkdir -p $INSTALL_DIR

# Install dependencies
sudo apt-get update
sudo apt-get install -y curl unzip openssl ca-certificates

# Download and setup Shinkai
echo "Downloading Shinkai ${SHINKAI_NODE_VERSION}..."
curl -L -o /tmp/shinkai-node.zip "https://download.shinkai.com/shinkai-node/binaries/production/x86_64-unknown-linux-gnu/${SHINKAI_NODE_VERSION}.zip"

# Verify Shinkai download size
if [ $(stat -c %s /tmp/shinkai-node.zip) -lt 26214400 ]; then
    echo "Error: shinkai-node file is less than 25MB"
    exit 1
fi

# Extract Shinkai
cd /tmp
unzip -o shinkai-node.zip
sudo mv shinkai-node $INSTALL_DIR/
sudo mv libpdfium.so $INSTALL_DIR/
sudo mv shinkai-tools-runner-resources $INSTALL_DIR/
sudo chmod +x $INSTALL_DIR/shinkai-node

# Create systemd service for Shinkai
cat << EOF | sudo tee /etc/systemd/system/shinkai.service
[Unit]
Description=Shinkai Node Service

[Service]
ExecStart=$INSTALL_DIR/shinkai-node
Environment=EMBEDDINGS_SERVER_URL=http://localhost:11434
Environment=FIRST_DEVICE_NEEDS_REGISTRATION_CODE=false
Environment=LOG_SIMPLE=true
Environment=NO_SECRET_FILE=true
Environment=REINSTALL_TOOLS=true
Environment=DEFAULT_EMBEDDING_MODEL=snowflake-arctic-embed:xs
Environment=RPC_URL=https://arbitrum-sepolia.blockpi.network/v1/rpc/public
Environment=PROXY_IDENTITY=@@relayer_pub_01.arb-sep-shinkai
Environment=LOG_ALL=1
Environment=INITIAL_AGENT_NAMES=o_llama3_1_8b_instruct_q4_1
Environment=INITIAL_AGENT_MODELS=ollama:llama3.1:8b-instruct-q4_1
Environment=NODE_API_IP=0.0.0.0
Environment=NODE_IP=0.0.0.0
Environment=NODE_API_PORT=80
Environment=NODE_WS_PORT=9551
Environment=NODE_PORT=9552
Environment=NODE_HTTPS_PORT=443
Environment=NODE_STORAGE_PATH=$INSTALL_DIR/node_storage
Environment=INITIAL_AGENT_URLS=http://localhost:11434
Environment=API_V2_KEY=PASTE_YOUR_API_V2_KEY_HERE
Environment=IDENTITY_SECRET_KEY=df3f619804a92fdb4057192dc43dd748ea778adc52bc498ce80524c014b81119
Environment=ENCRYPTION_SECRET_KEY=d83f619804a92fdb4057192dc43dd748ea778adc52bc498ce80524c014b81159
Environment=PING_INTERVAL_SECS=0
Environment=GLOBAL_IDENTITY_NAME=@@localhost.arb-sep-shinkai
Environment=RUST_LOG=debug,error,info
Environment=STARTING_NUM_QR_PROFILES=1
Environment=STARTING_NUM_QR_DEVICES=1
Environment=SHINKAI_TOOLS_RUNNER_DENO_BINARY_PATH=$INSTALL_DIR/shinkai-tools-runner-resources/deno
Environment=INITIAL_AGENT_API_KEYS=
Environment=LOG_ALL=1
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start services
sudo systemctl daemon-reload
sudo systemctl enable shinkai.service
sudo systemctl start shinkai.service

echo "Installation complete. Shinkai Node should start automatically on boot."