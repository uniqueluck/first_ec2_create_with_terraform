# terraformdemo — README

This README shows a step-by-step example to create an **EC2 instance using Terraform**. It covers installing Terraform, installing VS Code, configuring AWS CLI, generating an SSH key using `ssh-keygen`, creating your project folder (`terraformdemo`) and files (`ec2.tf`, `terraform.tf`, `provider.tf`), and running Terraform commands.

---

## 1. Install Terraform

### Windows
```powershell
choco install terraform -y
```
### macOS
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```
### Linux
Download from [Terraform Downloads](https://developer.hashicorp.com/terraform/downloads) and move the binary to `/usr/local/bin`.

Verify installation:
```bash
terraform -version
```

---

## 2. Install Visual Studio Code

Download from [https://code.visualstudio.com](https://code.visualstudio.com) and install Terraform extensions:
- HashiCorp Terraform
- YAML / Prettier

---

## 3. Configure AWS CLI

Install the AWS CLI and configure credentials:
```bash
aws configure
```
Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `ap-south-1`)
- Output format (e.g., `json`)

Verify setup:
```bash
aws sts get-caller-identity
```

---

## 4. Generate Public Key

After configuring AWS CLI, generate your SSH key pair using the following command:
```bash
ssh-keygen
```
Press **Enter** for default file name (`id_rsa`) or specify your own (e.g., `terra-key-ec2`). This command generates two files in your current folder:
- `terra-key-ec2` — Private key (keep safe, do **not** upload to GitHub)
- `terra-key-ec2.pub` — Public key (used in Terraform for the AWS key pair)

Add private key to `.gitignore` to avoid uploading it.

---

## 5. Create Project Folder & Files

```bash
mkdir terraformdemo
cd terraformdemo
```

Create the following files:
- `terraform.tf`
- `provider.tf`
- `ec2.tf`

### terraform.tf
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 1.0.0"
}
```

### provider.tf
```hcl
provider "aws" {
  region = "ap-south-1"
}
```

### ec2.tf
```hcl
resource "aws_default_vpc" "default" {}

resource "aws_key_pair" "my_key" {
  key_name   = "my_terra_key"
  public_key = file("terra-key-ec2.pub")
}

resource "aws_security_group" "my_sg" {
  name        = "terraform-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_ec2" {
  ami                    = "ami-0dee22c13ea7a9a67"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "Terraform-EC2"
  }
}
```

---

## 6. Initialize and Apply Terraform

```bash
terraform init
terraform plan
terraform apply
```
Type `yes` to confirm.

To destroy resources later:
```bash
terraform destroy
```

---

## 7. Push to GitHub

```bash
git init
git add .
git commit -m "EC2 instance using Terraform"
git branch -M main
git remote add origin <your_repo_url>
git push -u origin main
```

Add private key to `.gitignore` to avoid uploading sensitive files.

