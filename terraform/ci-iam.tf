# ci user for the gh action deploy pipeline
resource "aws_iam_user" "ci" {
  name = "oocaa-ci"
}

# push images to ecr (policy covers login and push actions)
resource "aws_iam_user_policy_attachment" "ci_ecr" {
  user = aws_iam_user.ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# let the pipeline open/close port 22 for the runner's ip, on our security group only
data "aws_iam_policy_document" "ci_sg" {
  statement {
    sid = "DescribeSGs"
    effect = "Allow"
    actions = ["ec2:DescribeSecurityGroups"]
    resources = ["*"] # Describe can't be resource-scoped
  }
  statement {
    sid = "ManageSSHRule"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
    ]
    resources = [aws_security_group.oocaa.arn] # only our security group
  }
}

resource "aws_iam_user_policy" "ci_sg" {
  name = "oocaa-ci-sg-ssh"
  user = aws_iam_user.ci.name
  policy = data.aws_iam_policy_document.ci_sg.json
}

resource "aws_iam_access_key" "ci" {
  user = aws_iam_user.ci.name
}

output "ci_access_key_id" {
  value = aws_iam_access_key.ci.id
}

output "ci_secret_access_key" {
  value = aws_iam_access_key.ci.secret
  sensitive = true
}