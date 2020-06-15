provider "aws" {
  region  = "ap-south-1"
  profile = "pkumar"
}

resource "tls_private_key" "privatekey" {
  algorithm   = "RSA"
}

resource "aws_key_pair" "keypair" {
  key_name   = "mykey"
  public_key = "${tls_private_key.privatekey.public_key_openssh}"
  depends_on = [tls_private_key.privatekey]
}

resource "local_file" "key" {
    content    = "${tls_private_key.privatekey.private_key_pem}"
    filename   = "mykey.pem"
    depends_on = [aws_key_pair.keypair]
}


resource "aws_security_group" "firewall" {
  name        = "mysg"
  description = "Allow TCP"
  vpc_id      = "vpc-8af4e0e2"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "defender"
  }
}
resource "aws_instance" "myOS" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "mykey"
  security_groups = ["mysg"]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${tls_private_key.privatekey.private_key_pem}"
    host     = aws_instance.myOS.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }
  
  tags = {
    Name = "LINUX"
  }
}

resource "aws_ebs_volume" "myebs" {
  availability_zone = aws_instance.myOS.availability_zone
  size              = 1

  tags = {
    Name = "MYEBS"
  }
}

resource "aws_volume_attachment" "EBS_ATTACH" {
  depends_on = [ 
         aws_ebs_volume.myebs,
  ]
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.myebs.id
  instance_id = aws_instance.myOS.id
  force_detach= true
}

resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.EBS_ATTACH,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${tls_private_key.privatekey.private_key_pem}"
    host     = aws_instance.myOS.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/pkrrsimtian/E-mandi.git /var/www/html/",
    ]
  }
}


resource "aws_s3_bucket" "pkumar_terraform" {
  acl    = "public-read"
  versioning {enabled=true}
}


resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.pkumar_terraform.bucket
  key    = "Static_images"
  acl = "public-read"
  source="myimages.jpg"
  etag = filemd5("myimages.jpg")
}

resource "aws_cloudfront_distribution" "Cloudfront_s3" {
depends_on = [
   null_resource.nullremote3,
  ]
  origin {
    domain_name = aws_s3_bucket.pkumar_terraform.bucket_regional_domain_name
    origin_id   = "cf_s3"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "images"
  default_root_object = "Static_images"
    default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "cf_s3"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "cf_s3"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "cf_s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
connection {
        type    = "ssh"
        user    = "ec2-user"
        private_key = "${tls_private_key.privatekey.private_key_pem}"
	host     = aws_instance.myOS.public_ip
    }
provisioner "remote-exec" {
        inline  = [
            # "sudo su << \"EOF\" \n echo \"<img src='${self.domain_name}'>\" >> /var/www/html/index.php \n \"EOF\""
            "sudo su << EOF",
            "echo \"<img src='http://${self.domain_name}/${aws_s3_bucket_object.object.key}' height='800px' width='600px'>\" >> /var/www/html/index.php",
            "EOF"
        ]
    }

}


resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote3,aws_cloudfront_distribution.Cloudfront_s3
  ]

	provisioner "local-exec" {
	    command = "firefox  ${aws_instance.myOS.public_ip}"
  	}
}
