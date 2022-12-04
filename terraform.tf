provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "tomcat-sg" {
  name = "x21201188-my-SG"
  description = "HTTP and SSH traffic"

  ingress {
    from_port   = 8080
    to_port     = 8080
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
}

resource "aws_instance" "my-EC2" {
  ami = "ami-01cae1550c0adea9c"
  instance_type = "t2.micro"
  key_name = "X21201188-AmzLinux"
  vpc_security_group_ids = [aws_security_group.private-sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = "30"
    delete_on_termination = true
  }
  user_data = <<EOF
#!/bin/bash
cd /opt
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
wget  https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.69/bin/apache-tomcat-9.0.69.tar.gz
tar -xvzf /opt/apache-tomcat-9.0.69.tar.gz
mv apache-tomcat-9.0.69 tomcat9
sudo chown -R ec2-user:ec2-user /opt/tomcat9
chmod +x /opt/tomcat9/bin/startup.sh 
chmod +x /opt/tomcat9/bin/shutdown.sh
ln -s /opt/tomcat9/bin/startup.sh /usr/local/bin/tomcatup
ln -s /opt/tomcat9/bin/shutdown.sh /usr/local/bin/tomcatdown
tomcatup

EOF

  tags = {
    Name = "x21201188-tomcat-deploy"
  }
}
