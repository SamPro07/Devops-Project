resource "aws_vpc" "Three-Tier-Web-App" {
  cidr_block = "10.0.0.0/16"

  instance_tenancy = "default"
  
  enable_dns_support = true

  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = false

  tags = { 
     Name = "Three-Tier-Web-App"
    }
  
}

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.Three-Tier-Web-App.id

  tags = {
     Name = "main"
  }
}

resource "aws_subnet" "Web_public_1" {
  
  vpc_id = aws_vpc.Three-Tier-Web-App.id

  cidr_block = "192.0.0.0/24"

  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
     Name = "public-us-east-1a"
     "Kubernetes.io/cluster/eks" = "shared"
     "kubernetes.io/role/elb"    = 1
  }

}

resource "aws_subnet" "Web_public_2" {
  
  vpc_id = aws_vpc.Three-Tier-Web-App.id

  cidr_block = "192.0.1.0/24"

  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
     Name = "public-us-east-1b"
     "Kubernetes.io/cluster/eks" = "shared"
     "kubernetes.io/role/elb"    = 1
  }

}


resource "aws_subnet" "App_private_1" {
  
  vpc_id = aws_vpc.Three-Tier-Web-App.id

  cidr_block = "192.168.1.0/24"

  availability_zone = "us-east-1a"

  tags = {
     Name = "public-us-east-1a"
     "Kubernetes.io/cluster/eks" = "shared"
     "kubernetes.io/role/elb"    = 1
  }

}

resource "aws_subnet" "App_private_2" {
  
  vpc_id = aws_vpc.Three-Tier-Web-App.id

  cidr_block = "192.168.2.0/24"

  availability_zone = "us-east-1b"

  tags = {
     Name = "public-us-east-1b"
     "Kubernetes.io/cluster/eks" = "shared"
     "kubernetes.io/role/elb"    = 1
  }

}

resource "aws_subnet" "DB_private_1" {
  
  vpc_id = aws_vpc.Three-Tier-Web-App.id

  cidr_block = "192.168.1.0/24"

  availability_zone = "us-east-1a"

  tags = {
     Name = "public-us-east-1a"
     "Kubernetes.io/cluster/eks" = "shared"
  }

}

resource "aws_subnet" "DB_private_2" {
  
  vpc_id = aws_vpc.Three-Tier-Web-App.id

  cidr_block = "192.168.2.0/24"

  availability_zone = "us-east-1b"

  tags = {
     Name = "public-us-east-1b"
     "Kubernetes.io/cluster/eks" = "shared"
  }

}

resource "aws_eip" "nat1" {
  
  depends_on = [ aws_internet_gateway.main ]

}

resource "aws_eip" "nat2" {
  
  depends_on = [ aws_internet_gateway.main ]

}

resource "aws_nat_gateway" "gw1" {
  
   allocation_id = aws_eip.nat1.id

   subnet_id = aws_subnet.Web_public_1.id

   tags = {
     Name = "NAT 1"
   }

}

resource "aws_nat_gateway" "gw2" {
  
   allocation_id = aws_eip.nat2.id

   subnet_id = aws_subnet.Web_public_2.id

   tags = {
     Name = "NAT 2"
   }

}

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.Three-Tier-Web-App.id

  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private1" {
   
   vpc_id = aws_vpc.Three-Tier-Web-App.id

   route {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.gw1.id
   }
  tags = {
     Name = "private1"
  }
}

resource "aws_route_table" "private2" {
   
   vpc_id = aws_vpc.Three-Tier-Web-App.id

   route {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.gw2.id
   }

  tags = {
     Name = "private2"
  }
}

resource "aws_route_table_association" "public1" {
    
    subnet_id = aws_subnet.Web_public_1.id

    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
    
    subnet_id = aws_subnet.Web_public_2.id

    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
    
    subnet_id = aws_subnet.App_private_1.id

    route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
    
    subnet_id = aws_subnet.App_private_2.id

    route_table_id = aws_route_table.private2.id
}