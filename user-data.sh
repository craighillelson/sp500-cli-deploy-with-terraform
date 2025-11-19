#!/bin/bash
# User data script for Amazon Linux 2023
# Exit on any error
set -e

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting user data script..."

# Install git
dnf install git -y

# Install Python 3 (includes pip on AL2023)
dnf install python3 -y

# Verify pip is available and upgrade it
python3 -m ensurepip --upgrade || true
python3 -m pip install --upgrade pip

# Install yfinance (ignore system packages to avoid conflicts)
echo "Installing yfinance..."
python3 -m pip install yfinance --ignore-installed requests

# Clone the S&P 500 CLI repository
echo "Cloning repository..."
cd /home/ec2-user
git clone https://github.com/craighillelson/sp500-cli.git
chown -R ec2-user:ec2-user /home/ec2-user/sp500-cli

echo "User data script completed successfully"
