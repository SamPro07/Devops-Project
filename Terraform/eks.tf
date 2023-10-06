resource "aws_iam_role" "EKS_cluster" {
   
   name = "eks-cluster"

   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  
}

resource "aws_iam_role_policy_attachment" "aws_eks_cluster_policy" {
   
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

   role = aws_iam_role.EKS_cluster.name
}

resource "aws_eks_cluster" "eks" {
  name     = "eks"
  role_arn = aws_iam_role.EKS_cluster.arn
  version = "1.18"

  vpc_config {
        endpoint_private_access = false 
        endpoint_public_access = true 

    subnet_ids = [
        aws_subnet.Web_public_1.id, 
        aws_subnet.Web_public_2.id,
        aws_subnet.App_private_1.id,
        aws_subnet.App_private_2.id,
        aws_subnet.DB_private_1.id,
        aws_subnet.DB_private_2.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
        aws_iam_role_policy_attachment.aws_eks_cluster_policy
  ]
}

resource "aws_iam_role" "nodes_general" {

    name = "eks-node-group-general"

    assume_role_policy = data.aws_iam_policy_document.assume_role_policy_EC2.json
  
}

resource "aws_iam_role_policy_attachment" "worker_nodes_policy_general" {

    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

    role = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_general" {

    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

    role = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {

    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

    role = aws_iam_role.nodes_general.name
}

resource "aws_eks_node_group" "nodes_general" {

  cluster_name = aws_eks_cluster.eks.name

  node_group_name = "nodes-general"

  node_role_arn = aws_iam_role.nodes_general.arn

  subnet_ids = [ 
        aws_subnet.App_private_1.id,
        aws_subnet.App_private_2.id,
        aws_subnet.DB_private_1.id,
        aws_subnet.DB_private_2.id
   ]
    

    scaling_config {

      desired_size = 3 
      
      max_size =  5  

      min_size = 2 
    }
   
   ami_type = "AL2_x86_64"
   
   capacity_type = "ON_DEMAND"

   disk_size = 20

   force_update_version = false 

   instance_types = [ "t3.small" ]

   labels = {
     role = "nodes-general"
   }

   version = "1.18"

   depends_on = [ 
        aws_iam_role_policy_attachment.worker_nodes_policy_general,
        aws_iam_role_policy_attachment.eks_cni_policy_general,
        aws_iam_role_policy_attachment.ec2_container_registry_read_only
    ]
}