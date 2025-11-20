# S&P 500 CLI App - Terraform Deployment

This Terraform configuration deploys your S&P 500 CLI application on an AWS EC2 instance running Amazon Linux 2023.

## Prerequisites

1. **Terraform installed** - [Download here](https://www.terraform.io/downloads)
2. **AWS CLI configured** with credentials - Run `aws configure`

## Files Included

- `main.tf` - Main Terraform configuration (EC2 instance and security group)
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values (instance ID, IP, DNS)
- `user-data.sh` - Bash script that runs on instance launch

## Setup Instructions

### 1. Configure Your Variables

Edit `terraform.tfvars` and set:
- `aws_region` - Your preferred AWS region (default: us-east-1)
- `instance_type` - Instance size (default: t2.micro)

### 2. Verify the AMI ID

The default AMI ID is for Amazon Linux 2023 in us-east-1. If you're using a different region, find the correct AMI ID:

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023.*-x86_64" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text
```

Update the `ami_id` variable in `terraform.tfvars` if needed.

### 3. Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider plugin.

### 4. Preview the Changes

```bash
terraform plan
```

Review what will be created.

### 5. Deploy

```bash
terraform apply
```

Type `yes` when prompted. Terraform will:
- Create a security group with SSH (port 22) and HTTP (port 5000) access
- Launch an EC2 instance
- Run the user-data script to install git, Python, yfinance, and clone your repo

### 6. Get Instance Information

After deployment, Terraform will display:
- Instance ID
- Public IP address
- Public DNS name

You can also view these anytime with:

```bash
terraform output
```

### 7. Connect to Your Instance

In the AWS Management Console, connect to your EC2 instance using EC2 Instance Connect.

### 8. Verify Installation

1. Once connected, check that everything deployed correctly.
1. `ls` should show sp500-cli directory.
1. Navigate into the directory: `cd sp500-cli`
1. Run the application: `python3 main.py`
1. You should see the rolling year average of the S&P 500 printed in the terminal.

## Cleanup

When you're done, destroy the resources to avoid charges:

```bash
terraform destroy
```

Type `yes` when prompted.

## Security Notes

⚠️ **Important**: The default security group allows SSH from anywhere (0.0.0.0/0). For production, restrict this to your IP:

In `main.tf`, change the SSH ingress rule:

```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["YOUR.IP.ADDRESS.HERE/32"]  # Your specific IP
}
```

## Customization

### Change Instance Type

Edit `terraform.tfvars`:
```hcl
instance_type = "t3.small"  # or t2.medium, etc.
```

### Add More Security Group Rules

Edit `main.tf` to add additional ingress rules for other ports your app needs.

### Modify User Data Script

Edit `user-data.sh` to add more installation steps, like:
- Installing Flask
- Setting up a systemd service
- Installing additional Python packages

## Troubleshooting

**Instance not accessible?**
- Check your security group rules
- Verify your key pair name is correct
- Ensure your AWS credentials are configured

**User data script failed?**
- SSH to the instance and check: `sudo cat /var/log/user-data.log`
- Look for error messages in the log

**Want to update the instance?**
- Modify `user-data.sh`
- Run `terraform apply -replace=aws_instance.sp500_app`

## Project Structure

```
.
├── main.tf                    # Main infrastructure
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── user-data.sh              # EC2 startup script
└── terraform.tfvars          # Your values (create from .example)
```

## Next Steps

Consider adding:
- Elastic IP for a static IP address
- Auto Scaling Group for high availability
- Application Load Balancer if running a web server
- CloudWatch alarms for monitoring
- S3 backend for Terraform state storage
