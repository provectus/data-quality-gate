data "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "connectable" {
  vpc_id = var.vpc_id
  name   = "dqg-s3-gateway-${var.env}"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ips
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ips
  }
}

resource "aws_instance" "s3_gateway" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  iam_instance_profile = aws_iam_instance_profile.web_instance_profile.id

  ebs_optimized     = false
  source_dest_check = "true"

  user_data = templatefile("${path.module}/user_data/nginx_install.tmpl.sh", {
    region      = data.aws_s3_bucket.data_bucket.region
    bucket_name = data.aws_s3_bucket.data_bucket.bucket
  })

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  subnet_id = var.instance_subnet_id

  vpc_security_group_ids = concat([aws_security_group.connectable.id], var.instance_sg_ids)
}
