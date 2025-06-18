resource "aws_iam_policy" "gitlab_runner_terraform_lambda_full_access" {
  name   = "gitlab_runner_terraform_lambda_full_access"
  policy = data.aws_iam_policy_document.gitlab_runner_terraform_lambda_full_access_document.json
}

data "aws_iam_policy_document" "gitlab_runner_terraform_lambda_full_access_document" {

  ##############################################
  #                                            #
  # /!\ THIS POLICY GRANTS ALL PRIVILEGES /!\  #
  #                                            #
  ##############################################

  # This policy is only supposed to be assigned to the gitlab runner terraform lambda to handle terraform changes on the whole infrastruture

  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "attach_gitlab_runner_terraform_lambda_full_access_to_gitlab_runner_terraform_lambda_full_access_role" {
  role       = aws_iam_role.gitlab_runner_terraform_lambda_full_access_role.id
  policy_arn = aws_iam_policy.gitlab_runner_terraform_lambda_full_access.arn
}

resource "aws_iam_role" "gitlab_runner_terraform_lambda_full_access_role" {
  name = "gitlab_runner_terraform_lambda_full_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "gitlab_runner_terraform_lambda" {

  function_name = "gitlab-runner-terraform-lambda"
  role          = aws_iam_role.gitlab_runner_terraform_lambda_full_access_role.arn

  image_uri    = data.aws_ecr_image.gitlab_runner_terraform_lambda_image.image_uri
  package_type = "Image"

  # in Python code, the lambda runs gitlab-runner for 500 seconds,
  # so we put a value a bit higher here;
  # this is also the value of both "cli-connect-timeout"
  # and "cli-read-timeout" when running "aws lambda invoke"
  timeout = 600

  # installing hashicorp/aws Terraform module hangs forever
  # if the memory capacity is let at its default 128 MB value;
  # we arbitrarily move it up to 1 GB
  memory_size = 1024

  reserved_concurrent_executions = 1

  # on June 2025, hashicorp/aws Terraform module size is around 148 MB;
  # this heavy module size causes the whole lambda temporary storage
  # to overflow its default 512 MB capacity
  ephemeral_storage {
    size = 1024 # 1024 MB
  }

  environment {
    variables = {
      AWS_USED_REGION = "eu-west-3"
    }
  }
}

resource "aws_ecr_repository" "gitlab_runner_terraform_lambda_image_repository" {
  name                 = "gitlab-runner-terraform-lambda"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_secretsmanager_secret" "gitlab_runner_terraform_credentials" {
  name = "credentials-for-gitlab-runner"
}

resource "aws_secretsmanager_secret_version" "gitlab_runner_terraform_credentials_secrets" {
  secret_id     = aws_secretsmanager_secret.gitlab_runner_terraform_credentials.id
  secret_string = jsonencode(var.gitlab_runner_terraform_all_secrets)
}

variable "gitlab_runner_terraform_all_secrets" {
  default = {
    SCW_ACCESS_KEY                   = ""
    SCW_SECRET_KEY                   = ""
    GITLAB_RUNNER_REGISTRATION_TOKEN = ""
    SCW_DEFAULT_ORGANIZATION         = ""
    SCW_DEFAULT_PROJECT              = ""
    SCW_DEFAULT_REGION               = ""
    SCW_DEFAULT_ZONE                 = ""
  }

  type = map(string)
}

data "aws_ecr_image" "gitlab_runner_terraform_lambda_image" {
  repository_name = "gitlab-runner-terraform-lambda"
  image_tag       = "latest"
}

resource "aws_iam_user" "gitlab_runner_terraform_lambda_user" {
  name = "gitlab-runner-terraform-lambda-user"
}

resource "aws_iam_user_login_profile" "gitlab_runner_terraform_lambda_user_login_profile" {
  user = aws_iam_user.gitlab_runner_terraform_lambda_user.name

  # this is the public key of a gpg key pair stored in a local keystore for the gitlab-runner-terraform-lambda user;
  # the private key part is locally stored; this is safe to put the public key here, used by AWS to encrypt the default password of the user
  pgp_key = ""
}

output "gitlab_runner_terraform_lambda_user_encrypted_password" {
  value = aws_iam_user_login_profile.gitlab_runner_terraform_lambda_user_login_profile.encrypted_password
}
