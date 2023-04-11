resource "aws_iam_instance_profile" "web_instance_profile" {
  name = "dqg-s3-gateway-profile-${var.env}"
  role = aws_iam_role.instance_role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "s3_read" {
  name = "dqg-s3-gateway-read-policy-${var.env}"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:Get*",
            "s3:List*"
          ],
          "Resource" : "${data.aws_s3_bucket.data_bucket.arn}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role" "instance_role" {
  name               = "dqg-s3-gateway-instance-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "push_report_dynamodb" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.s3_read.arn
}
