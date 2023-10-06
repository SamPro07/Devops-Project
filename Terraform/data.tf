data "aws_iam_policy_document" "assume_role_policy" {
   
   Version = "2012-10-17"
   
   statement {
     actions = ["sts:AssumeRole"]
     effect = ["Allow"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_EC2" {
   
   Version = "2012-10-17"
   
   statement {
     actions = ["sts:AssumeRole"]
     effect = ["Allow"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}