#!/usr/bin/env python3
"""
MCP Server for AWS - Simulated for workshop
Demonstrates how MCP servers bridge AI with AWS resources
"""

import json
import os
from typing import Dict, List, Any
from datetime import datetime

class AWSMCPServer:
    """
    Simulated AWS MCP Server for compliance checking
    In production, this would use boto3 to make real AWS API calls
    """
    
    def __init__(self):
        """Initialize with simulated AWS resources"""
        # Simulated S3 buckets (some compliant, some not)
        self.s3_buckets = [
            {
                "name": "prod-customer-data",
                "encryption": None,  # VIOLATION: No encryption
                "versioning": True,
                "public_access_blocked": True,
                "tags": {"Environment": "Production", "Owner": "data-team"}
            },
            {
                "name": "backup-2024",
                "encryption": "AES256",
                "versioning": False,  # VIOLATION: No versioning
                "public_access_blocked": True,
                "tags": {"Environment": "Production"}  # VIOLATION: Missing Owner tag
            },
            {
                "name": "logs-archive",
                "encryption": "aws:kms",
                "versioning": True,
                "public_access_blocked": False,  # VIOLATION: Public access not blocked
                "tags": {"Environment": "Production", "Owner": "ops-team"}
            },
            {
                "name": "dev-testing",
                "encryption": "AES256",
                "versioning": True,
                "public_access_blocked": True,
                "tags": {"Environment": "Development", "Owner": "dev-team"}
            }
        ]
        
        # Simulated EC2 instances
        self.ec2_instances = [
            {
                "id": "i-1234567890abcdef0",
                "name": "web-server-01",
                "state": "running",
                "tags": {"Name": "web-server-01", "Environment": "Production"},
                # VIOLATION: Missing required tags (Owner, CostCenter)
                "security_groups": ["sg-web", "sg-ssh"]
            },
            {
                "id": "i-0987654321fedcba0",
                "name": "db-server-01",
                "state": "running",
                "tags": {
                    "Name": "db-server-01",
                    "Environment": "Production",
                    "Owner": "db-team",
                    "CostCenter": "IT-500"
                },
                "security_groups": ["sg-database"]
            }
        ]
        
        # Simulated IAM policies
        self.iam_policies = [
            {
                "name": "AdminAccess",
                "arn": "arn:aws:iam::123456789012:policy/AdminAccess",
                "attached_to": ["admin-role"],
                "has_mfa": False  # VIOLATION: Admin without MFA
            },
            {
                "name": "ReadOnlyAccess",
                "arn": "arn:aws:iam::123456789012:policy/ReadOnlyAccess",
                "attached_to": ["developer-role"],
                "has_mfa": True
            }
        ]
    
    def list_s3_buckets(self) -> List[str]:
        """MCP Tool: List all S3 bucket names"""
        return [bucket["name"] for bucket in self.s3_buckets]
    
    def get_bucket_encryption(self, bucket_name: str) -> Dict[str, Any]:
        """MCP Tool: Get encryption status of a specific bucket"""
        for bucket in self.s3_buckets:
            if bucket["name"] == bucket_name:
                return {
                    "bucket": bucket_name,
                    "encryption": bucket["encryption"],
                    "compliant": bucket["encryption"] is not None
                }
        return {"error": f"Bucket {bucket_name} not found"}
    
    def get_bucket_details(self, bucket_name: str) -> Dict[str, Any]:
        """MCP Tool: Get all details of a bucket"""
        for bucket in self.s3_buckets:
            if bucket["name"] == bucket_name:
                return bucket
        return {"error": f"Bucket {bucket_name} not found"}
    
    def list_ec2_instances(self) -> List[Dict[str, str]]:
        """MCP Tool: List all EC2 instances"""
        return [
            {"id": inst["id"], "name": inst["name"], "state": inst["state"]}
            for inst in self.ec2_instances
        ]
    
    def get_instance_tags(self, instance_id: str) -> Dict[str, Any]:
        """MCP Tool: Get tags for a specific EC2 instance"""
        for instance in self.ec2_instances:
            if instance["id"] == instance_id:
                return {
                    "instance_id": instance_id,
                    "tags": instance["tags"],
                    "required_tags": ["Name", "Environment", "Owner", "CostCenter"],
                    "missing_tags": [
                        tag for tag in ["Name", "Environment", "Owner", "CostCenter"]
                        if tag not in instance["tags"]
                    ]
                }
        return {"error": f"Instance {instance_id} not found"}
    
    def list_iam_policies(self) -> List[Dict[str, str]]:
        """MCP Tool: List all IAM policies"""
        return [
            {"name": policy["name"], "arn": policy["arn"]}
            for policy in self.iam_policies
        ]
    
    def check_mfa_status(self, policy_name: str) -> Dict[str, Any]:
        """MCP Tool: Check MFA status for a policy"""
        for policy in self.iam_policies:
            if policy["name"] == policy_name:
                return {
                    "policy": policy_name,
                    "has_mfa": policy["has_mfa"],
                    "compliant": policy["has_mfa"] or "Admin" not in policy_name
                }
        return {"error": f"Policy {policy_name} not found"}
    
    def get_compliance_summary(self) -> Dict[str, Any]:
        """MCP Tool: Get overall compliance summary"""
        s3_violations = 0
        ec2_violations = 0
        iam_violations = 0
        
        # Check S3 compliance
        for bucket in self.s3_buckets:
            if not bucket["encryption"]:
                s3_violations += 1
            if not bucket["versioning"]:
                s3_violations += 1
            if not bucket["public_access_blocked"]:
                s3_violations += 1
            if "Owner" not in bucket.get("tags", {}):
                s3_violations += 1
        
        # Check EC2 compliance
        for instance in self.ec2_instances:
            required_tags = ["Name", "Environment", "Owner", "CostCenter"]
            missing = [tag for tag in required_tags if tag not in instance["tags"]]
            if missing:
                ec2_violations += len(missing)
        
        # Check IAM compliance
        for policy in self.iam_policies:
            if "Admin" in policy["name"] and not policy["has_mfa"]:
                iam_violations += 1
        
        total_resources = len(self.s3_buckets) + len(self.ec2_instances) + len(self.iam_policies)
        total_violations = s3_violations + ec2_violations + iam_violations
        
        return {
            "timestamp": datetime.now().isoformat(),
            "resources_scanned": total_resources,
            "total_violations": total_violations,
            "s3_violations": s3_violations,
            "ec2_violations": ec2_violations,
            "iam_violations": iam_violations,
            "compliance_score": f"{((total_resources - total_violations) / total_resources * 100):.1f}%"
        }


def main():
    """Test the MCP server"""
    server = AWSMCPServer()
    
    print("🔌 AWS MCP Server (Simulated)")
    print("=" * 50)
    
    # Test listing buckets
    buckets = server.list_s3_buckets()
    print(f"\n📦 S3 Buckets: {buckets}")
    
    # Test checking encryption
    for bucket in buckets:
        encryption = server.get_bucket_encryption(bucket)
        status = "✅" if encryption["compliant"] else "❌"
        print(f"  {status} {bucket}: {encryption.get('encryption', 'None')}")
    
    # Test EC2 instances
    instances = server.list_ec2_instances()
    print(f"\n🖥️ EC2 Instances: {len(instances)} found")
    
    for instance in instances:
        tags = server.get_instance_tags(instance["id"])
        if tags.get("missing_tags"):
            print(f"  ❌ {instance['name']}: Missing tags {tags['missing_tags']}")
        else:
            print(f"  ✅ {instance['name']}: All tags present")
    
    # Get summary
    summary = server.get_compliance_summary()
    print(f"\n📊 Compliance Summary:")
    print(f"  Resources: {summary['resources_scanned']}")
    print(f"  Violations: {summary['total_violations']}")
    print(f"  Score: {summary['compliance_score']}")


if __name__ == "__main__":
    main()