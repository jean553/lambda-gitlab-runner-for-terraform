resource "aws_iam_group_membership" "can_run_gitlab_runner_terraform_lambda" {
  name = "can-run-gitlab-runner-terraform-lambda"

  users = [
    aws_iam_user.gitlab_runner_terraform_lambda_user.name,
  ]

  group = aws_iam_group.can_run_gitlab_runner_terraform_lambda.name
}

resource "aws_iam_group" "can_run_gitlab_runner_terraform_lambda" {
  name = "can-run-gitlab-runner-terraform-lambda"
}

resource "aws_iam_group_policy_attachment" "can_run_gitlab_runner_terraform_lambda" {
  group      = aws_iam_group.can_run_gitlab_runner_terraform_lambda.name
  policy_arn = aws_iam_policy.can_run_gitlab_runner_terraform_lambda.arn
}

resource "aws_iam_policy" "can_run_gitlab_runner_terraform_lambda" {
  name = "can_run_gitlab_runner_terraform_lambda"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Resource": "${aws_lambda_function.gitlab_runner_terraform_lambda.arn}"
      }
    ]
  }
  EOF
}

