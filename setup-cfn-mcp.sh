#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "    CFN MCP Server Setup Script"
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
check_command claude || {
    echo -e "${RED}❌ Claude Code CLI is not installed. Please install it first.${NC}"
    exit 1
}

check_command uvx || {
    echo -e "${YELLOW}⚠️  uvx not found. Installing uv package manager...${NC}"
    show_command "pip install uv --break-system-packages"
    pip install uv --break-system-packages &> /dev/null
    echo -e "${GREEN}✓${NC} uv package manager installed"
}

# Install CFN MCP Server
echo -e "\n${BLUE}Step 2.1: Installing CFN MCP Server...${NC}"
echo "----------------------------------------"
show_command "claude mcp add cfn-server --scope user -- uvx awslabs.cfn-mcp-server@latest"
claude mcp add cfn-server --scope user -- uvx awslabs.cfn-mcp-server@latest

# Install Context7 MCP Server
echo -e "\n${BLUE}Step 2.2: Installing Context7 MCP Server...${NC}"
echo "----------------------------------------"
show_command "claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp@latest"
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp@latest

# Install Terraform MCP Server
echo -e "\n${BLUE}Step 2.3: Installing Terraform MCP Server...${NC}"
echo "----------------------------------------"
show_command "claude mcp add terraform --scope user -- uvx awslabs.terraform-mcp-server@latest"
claude mcp add terraform --scope user -- uvx awslabs.terraform-mcp-server@latest

# Verify installation
echo -e "\n${BLUE}Step 3: Verifying installation...${NC}"
echo "----------------------------------------"
show_command "claude mcp list > /root/mcp-configured.txt 2>&1"
claude mcp list > /root/mcp-configured.txt 2>&1

# Show the output
echo -e "${BLUE}MCP Server List Output:${NC}"
cat /root/mcp-configured.txt
echo ""

# Check if installation was successful
echo -e "${BLUE}Step 4: Validating configuration...${NC}"
echo "----------------------------------------"
if grep -q "cfn-server" /root/mcp-configured.txt && grep -q "context7" /root/mcp-configured.txt && grep -q "terraform" /root/mcp-configured.txt; then
    # Add marker for validation
    echo "CFN_MCP_CONFIGURED" >> /root/mcp-configured.txt
    echo "TERRAFORM_MCP_CONFIGURED" >> /root/mcp-configured.txt

    echo -e "${GREEN}✅ All MCP Servers successfully installed and configured!${NC}"
    echo -e "${GREEN}📄 Configuration saved to: /root/mcp-configured.txt${NC}"

    # Display the server status
    echo -e "\n${BLUE}📊 MCP Server Status:${NC}"
    echo "----------------------------------------"
    echo -e "${GREEN}✓ CloudFormation MCP:${NC}"
    grep "cfn-server" /root/mcp-configured.txt
    echo -e "${GREEN}✓ Context7 MCP:${NC}"
    grep "context7" /root/mcp-configured.txt
    echo -e "${GREEN}✓ Terraform MCP:${NC}"
    grep "terraform" /root/mcp-configured.txt
    echo ""

    # Show validation markers
    echo -e "${GREEN}✓ Validation markers added: CFN_MCP_CONFIGURED, TERRAFORM_MCP_CONFIGURED${NC}"
else
    echo -e "${RED}❌ MCP Server installation failed${NC}"
    echo -e "${RED}Please check the output above for errors${NC}"
    exit 1
fi

echo -e "\n${BLUE}=========================================="
echo -e "${GREEN}    Setup Complete Successfully!"
echo -e "${BLUE}==========================================${NC}"
echo ""
echo "You can verify the installation by running:"
echo -e "  ${BLUE}claude mcp list${NC}"
echo ""
echo "Or check the configuration file:"
echo -e "  ${BLUE}cat /root/mcp-configured.txt${NC}"