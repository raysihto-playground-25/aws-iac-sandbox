# AWS Setup Guide

This guide walks you through setting up an IAM user and configuring the AWS CLI for use with IaC tools.

## Prerequisites

- An AWS account (sign up at https://aws.amazon.com if you don't have one)
- Linux/bash environment (WSL2 on Windows, native Linux, or macOS)

## Step 1: Create an IAM User

### Using AWS Console

1. **Sign in to AWS Console**
   - Go to https://console.aws.amazon.com
   - Sign in with your root account or existing IAM user

2. **Navigate to IAM**
   - Search for "IAM" in the services search bar
   - Click on "IAM" (Identity and Access Management)

3. **Create a New User**
   - Click "Users" in the left sidebar
   - Click "Create user"
   - Enter username: `iac-deployer` (or your preferred name)
   - Click "Next"

4. **Set Permissions**
   - Select "Attach policies directly"
   - Search for and select these policies:
     - `AmazonS3FullAccess` (for S3 bucket management)
     - `IAMReadOnlyAccess` (optional, for viewing IAM resources)
   - Click "Next"

   > **Note**: For production, use more restrictive policies. These are for learning purposes.

5. **Review and Create**
   - Review the settings
   - Click "Create user"

6. **Create Access Keys**
   - Click on the newly created user
   - Go to "Security credentials" tab
   - Scroll to "Access keys" section
   - Click "Create access key"
   - Select "Command Line Interface (CLI)"
   - Check the confirmation box
   - Click "Next"
   - Add description tag (optional): "IaC learning repository"
   - Click "Create access key"
   - **Important**: Copy the Access Key ID and Secret Access Key
     - Download the CSV file or save them securely
     - You won't be able to see the secret key again!

## Step 2: Install AWS CLI

### On Linux (Debian/Ubuntu)

```bash
# Download AWS CLI installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the installer
unzip awscliv2.zip

# Run the installer
sudo ./aws/install

# Verify installation
aws --version
```

### On macOS

```bash
# Using Homebrew
brew install awscli

# Or using the official installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Verify installation
aws --version
```

### Expected Output
```
aws-cli/2.x.x Python/3.x.x Linux/x.x.x exe/x86_64.ubuntu.xx
```

## Step 3: Configure AWS CLI

### Configure with Access Keys

```bash
aws configure
```

When prompted, enter:
- **AWS Access Key ID**: (paste the Access Key ID from Step 1)
- **AWS Secret Access Key**: (paste the Secret Access Key from Step 1)
- **Default region name**: `us-east-1` (or your preferred region)
- **Default output format**: `json`

### Verify Configuration

```bash
# Test AWS CLI is configured correctly
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/iac-deployer"
}
```

### Alternative: Using AWS SSO (Optional)

If your organization uses AWS SSO:

```bash
aws configure sso
```

Follow the prompts to configure SSO access.

## Step 4: Set Up Environment Variables (Optional)

For additional security, you can use environment variables instead of storing credentials in `~/.aws/credentials`:

```bash
# Add to your ~/.bashrc or ~/.zshrc
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

Then reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Step 5: Verify Permissions

Test that your IAM user can list S3 buckets:

```bash
aws s3 ls
```

If you don't have any buckets yet, this will return empty output (not an error).

## Security Best Practices

1. **Never commit credentials** to version control
   - AWS credentials are in `~/.aws/credentials`
   - Environment variables should be in shell config files (add to .gitignore)

2. **Use MFA** (Multi-Factor Authentication) for IAM users when possible

3. **Rotate access keys** regularly (every 90 days recommended)

4. **Use least privilege**: Grant only the permissions needed
   - For production: Create custom policies instead of using `*FullAccess`

5. **Enable CloudTrail** to audit AWS API calls

6. **Delete unused access keys**

## Troubleshooting

### "Unable to locate credentials"
- Run `aws configure` again
- Check `~/.aws/credentials` exists and has correct format
- Verify environment variables if using that method

### "Access Denied" errors
- Verify IAM user has required permissions
- Check policy attachments in IAM console
- Ensure access keys are from the correct IAM user

### Region-related errors
- Verify `AWS_DEFAULT_REGION` or `~/.aws/config` has correct region
- Some services are not available in all regions

## Next Steps

Once AWS CLI is configured, proceed to:
- [Local Environment Setup](02-local-environment.md)
- Install IaC tools (Terraform, CDK, etc.)
