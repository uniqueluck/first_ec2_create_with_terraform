#keypair
resource "aws_key_pair" "mykey" {
key_name = "terra-key-ec2"
public_key = file("terra-key-ec2.pub")
}

#vpc & sg
resource "aws_default_vpc" "default"{

}

resource "aws_security_group" "mysg" {
    name = "terra-sg"
    description = "this wiil add a TF generated sg"
    vpc_id = aws_default_vpc.default.id   
    #interpollation- it is way in which you can inherrit or extract the values from a terraform block
  
  #inbound rules
   ingress  {
    from_port = 22
    to_port =22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH OPEN"

   }

   ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTP OPEN"

   }
   #outbond rules
   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
   description = "all access open"

   }

 }

 #aws instance

 resource "aws_instance" "my_ec2"{
    key_name = aws_key_pair.mykey.key_name
    security_groups = [ aws_security_group.mysg.name ]
    instance_type = "t3.micro"
    ami = "ami-0f5fcdfbd140e4ab7" # ubuntu
    root_block_device {
      volume_size = 8
      volume_type = "gp3"
    }
   tags = {
     Name = "my_first_ec2_with_terra"
   }
 }
