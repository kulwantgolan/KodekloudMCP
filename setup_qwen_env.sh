#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up Qwen environment...${NC}"

# Create .qwen directory if it doesn't exist
if [ ! -d "/root/.qwen" ]; then
    echo "Creating /root/.qwen directory..."
    mkdir -p /root/.qwen
    echo -e "${GREEN}✓${NC} Directory created: /root/.qwen"
else
    echo -e "${GREEN}✓${NC} Directory already exists: /root/.qwen"
fi

# Copy settings_before.json to .qwen/settings.json
if [ -f "/root/settings_before.json" ]; then
    echo "Copying MCP configuration..."
    cp /root/settings_before.json /root/.qwen/settings.json
    echo -e "${GREEN}✓${NC} Configuration copied to /root/.qwen/settings.json"
    echo ""
    echo -e "${GREEN}Qwen environment setup complete!${NC}"
else
    echo -e "${YELLOW}Warning: /root/settings_before.json not found${NC}"
    echo "Please ensure the settings_before.json file exists in /root/"
    exit 1
fi