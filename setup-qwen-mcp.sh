#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "    Qwen MCP Server Setup Script"
echo "==========================================${NC}"
echo ""

# Function to check command existence
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

# Function to show command being executed
show_command() {
    echo -e "\n${YELLOW}📍 Executing:${NC}"
    echo -e "${BLUE}    $1${NC}"
    echo ""
}

# Check prerequisites
echo -e "${BLUE}Step 1: Checking prerequisites...${NC}"
echo "----------------------------------------"
check_command qwen || {
    echo -e "${RED}❌ Qwen CLI is not installed. Installing...${NC}"
    npm install -g @qwen-code/qwen-code@latest
    echo -e "${GREEN}✓${NC} Qwen CLI installed"
}

check_command uvx || {
    echo -e "${YELLOW}⚠️  uvx not found. Installing uv package manager...${NC}"
    show_command "pip install uv --break-system-packages"
    pip install uv --break-system-packages &> /dev/null
    echo -e "${GREEN}✓${NC} uv package manager installed"
}

# Setup Qwen configuration directory
echo -e "\n${BLUE}Step 2: Setting up Qwen configuration...${NC}"
echo "----------------------------------------"
echo -e "${YELLOW}Creating .qwen directory...${NC}"
mkdir -p /root/.qwen

echo -e "${YELLOW}Copying settings.json with MCP servers configuration...${NC}"
if [ -f /root/settings.json ]; then
    cp /root/settings_before.json /root/.qwen/settings.json
    echo -e "${GREEN}✓${NC} Configuration copied to /root/.qwen/settings.json"
else
    echo -e "${RED}❌ settings.json not found in /root/${NC}"
    exit 1
fi

# Display configuration
echo -e "\n${BLUE}Step 3: Verifying MCP Server Configuration...${NC}"
echo "----------------------------------------"
echo -e "${YELLOW}Configured MCP Servers:${NC}"
if [ -f /root/.qwen/settings.json ]; then
    # Extract MCP server names from settings.json
    echo -e "${BLUE}Reading configuration...${NC}"
    if command -v jq &> /dev/null; then
        jq '.mcpServers | keys[]' /root/.qwen/settings.json 2>/dev/null | sed 's/"//g' | while read server; do
            echo -e "  ${GREEN}•${NC} $server"
        done
    else
        # Fallback if jq is not available
        grep -E '"cfn-mcp-server"|"awslabs.aws-documentation-mcp-server"|"awslabs.terraform-mcp-server"' /root/.qwen/settings.json &> /dev/null && {
            echo -e "  ${GREEN}•${NC} cfn-mcp-server"
            echo -e "  ${GREEN}•${NC} awslabs.aws-documentation-mcp-server"
            echo -e "  ${GREEN}•${NC} awslabs.terraform-mcp-server"
        }
    fi
fi

# List MCP servers
echo -e "\n${BLUE}Step 4: Checking MCP Server Status...${NC}"
echo "----------------------------------------"
show_command "qwen mcp list"

# Capture the output
qwen mcp list > /root/qwen-mcp-configured.txt 2>&1

# Show the output
echo -e "${BLUE}MCP Server List Output:${NC}"
cat /root/qwen-mcp-configured.txt
echo ""

# Verify all servers are configured
echo -e "${BLUE}Step 5: Validating all MCP servers...${NC}"
echo "----------------------------------------"

SERVERS_OK=true

# Check CloudFormation MCP Server
if grep -q "cfn-mcp-server" /root/qwen-mcp-configured.txt; then
    echo -e "${GREEN}✓ CloudFormation MCP Server:${NC} Configured"
else
    echo -e "${RED}✗ CloudFormation MCP Server:${NC} Not found"
    SERVERS_OK=false
fi

# Check AWS Documentation MCP Server
if grep -q "aws-documentation-mcp-server\|awslabs.aws-documentation-mcp-server" /root/qwen-mcp-configured.txt; then
    echo -e "${GREEN}✓ AWS Documentation MCP Server:${NC} Configured"
else
    echo -e "${RED}✗ AWS Documentation MCP Server:${NC} Not found"
    SERVERS_OK=false
fi

# Check Terraform MCP Server
if grep -q "terraform-mcp-server\|awslabs.terraform-mcp-server" /root/qwen-mcp-configured.txt; then
    echo -e "${GREEN}✓ Terraform MCP Server:${NC} Configured"
else
    echo -e "${RED}✗ Terraform MCP Server:${NC} Not found"
    SERVERS_OK=false
fi

# Final validation
if [ "$SERVERS_OK" = true ]; then
    # Add validation markers
    echo "" >> /root/qwen-mcp-configured.txt
    echo "QWEN_MCP_CONFIGURED" >> /root/qwen-mcp-configured.txt
    echo "CFN_MCP_CONFIGURED" >> /root/qwen-mcp-configured.txt
    echo "AWS_DOCS_MCP_CONFIGURED" >> /root/qwen-mcp-configured.txt
    echo "TERRAFORM_MCP_CONFIGURED" >> /root/qwen-mcp-configured.txt

    echo -e "\n${GREEN}✅ All MCP Servers successfully configured!${NC}"
    echo -e "${GREEN}📄 Configuration saved to:${NC}"
    echo -e "    • /root/.qwen/settings.json (MCP configuration)"
    echo -e "    • /root/qwen-mcp-configured.txt (status output)"

    # Display summary
    echo -e "\n${BLUE}📊 MCP Server Summary:${NC}"
    echo "----------------------------------------"
    echo -e "${GREEN}✓ CloudFormation MCP:${NC} Query and manage AWS resources"
    echo -e "${GREEN}✓ AWS Documentation MCP:${NC} Search and retrieve AWS docs"
    echo -e "${GREEN}✓ Terraform MCP:${NC} IaC automation with security scanning"
else
    echo -e "\n${RED}❌ Some MCP servers are not configured properly${NC}"
    echo -e "${YELLOW}Please check the settings.json file and ensure all servers are properly defined${NC}"
    exit 1
fi

echo -e "\n${BLUE}=========================================="
echo -e "${GREEN}    Setup Complete Successfully!"
echo -e "${BLUE}==========================================${NC}"
echo ""
echo "You can verify the installation by running:"
echo -e "  ${BLUE}qwen mcp list${NC}"
echo ""
echo "In Qwen, use the /mcp command to check server status:"
echo -e "  ${BLUE}/mcp${NC}"
echo ""
echo "Configuration files:"
echo -e "  ${BLUE}cat /root/.qwen/settings.json${NC} - MCP server configuration"
echo -e "  ${BLUE}cat /root/qwen-mcp-configured.txt${NC} - Setup validation output"