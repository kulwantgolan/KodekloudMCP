#!/bin/bash

echo "========================================================="
echo "AI Free Week Day 3 - CloudFormation MCP Server Setup"
echo "========================================================="

# Check Python version
echo "Checking Python version..."
if command -v python3 &> /dev/null; then
    python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    echo "Python $python_version is installed"
else
    echo "Python 3 is not installed"
fi

ln -s /usr/bin/python3 /usr/bin/python 2>/dev/null || true

# Install UV package manager
echo -e "\nInstalling UV package manager..."
pip install --upgrade pip --break-system-packages &> /dev/null
pip install uv --break-system-packages &> /dev/null
echo "UV package manager installed"

# Install AWS CLI if not present
echo -e "\nChecking AWS CLI..."
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    pip install awscli --break-system-packages &> /dev/null
fi
echo "AWS CLI ready"

# Install uvx for MCP server
echo -e "\nInstalling uvx for MCP servers..."
pip install uvx --break-system-packages &> /dev/null || true
echo "uvx installed"

# Pre-configure Claude Code trust settings
echo -e "\nConfiguring Claude Code trust settings..."
mkdir -p /root/.claude-code-router
cat > /root/.claude-code-router/trusted_paths.json << 'EOF'
{
  "trustedPaths": [
    "/root",
    "/root/mcp-compliance"
  ]
}
EOF
echo "Claude Code trust settings configured"

# Setup environment variables
echo 'export ANTHROPIC_BASE_URL="http://localhost:4000"' >> ~/.bashrc
echo 'export ANTHROPIC_AUTH_TOKEN="sk-test-123"' >> ~/.bashrc
echo 'export AWS_PROFILE="default"' >> ~/.bashrc
echo 'export AWS_REGION="us-east-1"' >> ~/.bashrc
source /root/.bashrc 2>/dev/null || true
source /root/.bash_profile 2>/dev/null || true

# Copy config and start litellm
cp /root/config.yaml /var/config.yaml 2>/dev/null || true
cd /var/
nohup env LITELLM_LOG=DEBUG litellm --config config.yaml > output.log 2>&1 &

# Setup MCP workspace
echo -e "\nSetting up MCP compliance workspace..."
mkdir -p /root/mcp-compliance
cd /root/mcp-compliance

# Create sample AWS credentials for demo
mkdir -p /root/.aws
cat > /root/.aws/credentials << 'EOF'
[default]
aws_access_key_id = AKIAEXAMPLE123456789
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF

cat > /root/.aws/config << 'EOF'
[default]
region = us-east-1
output = json
EOF

# Create simulated MCP CloudFormation server
cat > /root/mcp-compliance/cfn_mcp_server.py << 'EOF'
#!/usr/bin/env python3
"""
Simulated CloudFormation MCP Server for workshop
Demonstrates MCP server capabilities for AWS resource management
"""

import json
import os
from typing import Dict, List, Any
from datetime import datetime

class CloudFormationMCPServer:
    """
    Simulated CloudFormation MCP Server using Cloud Control API
    In production, this would use boto3 and real AWS APIs
    """
    
    def __init__(self):
        """Initialize with simulated resources"""
        self.resources = {}
        self.templates = {}
    
    def create_resource(self, resource_type: str, properties: Dict[str, Any]) -> Dict[str, Any]:
        """MCP Tool: Create AWS resource using Cloud Control API"""
        resource_id = f"{resource_type}-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        if resource_type == "AWS::S3::Bucket":
            bucket_name = properties.get("BucketName", f"bucket-{resource_id}")
            self.resources[resource_id] = {
                "Type": resource_type,
                "Properties": properties,
                "ARN": f"arn:aws:s3:::{bucket_name}",
                "Status": "CREATE_COMPLETE"
            }
            return {
                "ResourceId": resource_id,
                "ARN": f"arn:aws:s3:::{bucket_name}",
                "Status": "CREATE_COMPLETE",
                "Message": f"S3 bucket '{bucket_name}' created successfully"
            }
        
        elif resource_type == "AWS::EC2::SecurityGroup":
            sg_name = properties.get("GroupName", f"sg-{resource_id}")
            self.resources[resource_id] = {
                "Type": resource_type,
                "Properties": properties,
                "GroupId": f"sg-{resource_id[-12:]}",
                "Status": "CREATE_COMPLETE"
            }
            return {
                "ResourceId": resource_id,
                "GroupId": f"sg-{resource_id[-12:]}",
                "Status": "CREATE_COMPLETE",
                "Message": f"Security group '{sg_name}' created successfully"
            }
        
        return {"error": f"Resource type {resource_type} not supported"}
    
    def get_resource(self, resource_id: str) -> Dict[str, Any]:
        """MCP Tool: Get resource details"""
        if resource_id in self.resources:
            return self.resources[resource_id]
        return {"error": f"Resource {resource_id} not found"}
    
    def update_resource(self, resource_id: str, properties: Dict[str, Any]) -> Dict[str, Any]:
        """MCP Tool: Update existing resource"""
        if resource_id in self.resources:
            self.resources[resource_id]["Properties"].update(properties)
            self.resources[resource_id]["Status"] = "UPDATE_COMPLETE"
            return {
                "ResourceId": resource_id,
                "Status": "UPDATE_COMPLETE",
                "Message": "Resource updated successfully"
            }
        return {"error": f"Resource {resource_id} not found"}
    
    def delete_resource(self, resource_id: str) -> Dict[str, Any]:
        """MCP Tool: Delete resource"""
        if resource_id in self.resources:
            del self.resources[resource_id]
            return {
                "ResourceId": resource_id,
                "Status": "DELETE_COMPLETE",
                "Message": "Resource deleted successfully"
            }
        return {"error": f"Resource {resource_id} not found"}
    
    def list_resources(self, resource_type: str = None) -> List[Dict[str, Any]]:
        """MCP Tool: List resources by type"""
        if resource_type:
            return [
                {"ResourceId": rid, **details}
                for rid, details in self.resources.items()
                if details["Type"] == resource_type
            ]
        return [
            {"ResourceId": rid, **details}
            for rid, details in self.resources.items()
        ]
    
    def create_template(self) -> Dict[str, Any]:
        """MCP Tool: Generate CloudFormation template from current resources"""
        template = {
            "AWSTemplateFormatVersion": "2010-09-09",
            "Description": "CloudFormation template generated by MCP server",
            "Resources": {}
        }
        
        for resource_id, details in self.resources.items():
            logical_id = resource_id.replace(":", "").replace("-", "")
            template["Resources"][logical_id] = {
                "Type": details["Type"],
                "Properties": details["Properties"]
            }
        
        # Save template
        with open("/root/mcp-compliance/infrastructure-template.yaml", "w") as f:
            import yaml
            yaml.dump(template, f, default_flow_style=False)
        
        return {
            "TemplateGenerated": True,
            "ResourceCount": len(self.resources),
            "FilePath": "/root/mcp-compliance/infrastructure-template.yaml",
            "Message": "CloudFormation template generated successfully"
        }

def main():
    """Test the MCP server"""
    server = CloudFormationMCPServer()
    
    print("🔌 CloudFormation MCP Server (Simulated)")
    print("=" * 50)
    
    # Test creating S3 bucket
    bucket_result = server.create_resource(
        "AWS::S3::Bucket",
        {
            "BucketName": "compliance-data-bucket-2025",
            "BucketEncryption": {
                "ServerSideEncryptionConfiguration": [{
                    "ServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }]
            },
            "VersioningConfiguration": {"Status": "Enabled"},
            "Tags": [
                {"Key": "Environment", "Value": "Production"},
                {"Key": "Owner", "Value": "compliance-team"}
            ]
        }
    )
    print(f"\n✅ Bucket Creation: {bucket_result['Message']}")
    
    # Test creating security group
    sg_result = server.create_resource(
        "AWS::EC2::SecurityGroup",
        {
            "GroupName": "compliance-sg",
            "GroupDescription": "Security group for compliance servers",
            "SecurityGroupIngress": [
                {
                    "IpProtocol": "tcp",
                    "FromPort": 22,
                    "ToPort": 22,
                    "CidrIp": "10.0.0.0/8"
                },
                {
                    "IpProtocol": "tcp",
                    "FromPort": 443,
                    "ToPort": 443,
                    "CidrIp": "0.0.0.0/0"
                }
            ]
        }
    )
    print(f"✅ Security Group Creation: {sg_result['Message']}")
    
    # Generate template
    template_result = server.create_template()
    print(f"\n📄 Template Generation: {template_result['Message']}")
    print(f"   Resources: {template_result['ResourceCount']}")
    print(f"   Location: {template_result['FilePath']}")

if __name__ == "__main__":
    main()
EOF

chmod +x /root/mcp-compliance/cfn_mcp_server.py

echo -e "\n✅ Environment ready for Day 3 Workshop!"
echo "CloudFormation MCP Server configured for infrastructure automation!"
echo "Use natural language to provision AWS resources!"