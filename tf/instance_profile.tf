locals {
  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

resource "aws_iam_instance_profile" "unbound" {
  name = "EC2-Profile"
  role = aws_iam_role.unbound.name
}

resource "aws_iam_role_policy_attachment" "unbound" {
  count = length(local.role_policy_arns)

  role       = aws_iam_role.unbound.name
  policy_arn = element(local.role_policy_arns, count.index)
}

resource "aws_iam_role_policy" "unbound" {
  name = "EC2-Inline-Policy"
  role = aws_iam_role.unbound.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameter"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role" "unbound" {
  name = "EC2-Role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}
