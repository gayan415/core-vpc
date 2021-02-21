resource "aws_iam_role" "flow_log_role" {
  name = "${var.environment}_${var.region}_flow_log_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "${var.environment}_${var.region}_flow_log_policy"
  role = aws_iam_role.flow_log_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name              = "${var.environment}_${var.region}_flow_log_group"
  retention_in_days = "365"
}

resource "aws_flow_log" "flow_log" {
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  vpc_id          = aws_vpc.vpc.id
  traffic_type    = "ALL"
}
