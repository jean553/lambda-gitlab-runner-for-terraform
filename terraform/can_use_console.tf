# the only purpose of this file is to allow the gitlab-runner-terraform-lambda user to:
# - have its own password and require him to use MFA everytime he wants to login, 
# - just enough privileges to trigger the gitlab-runner-terraform lambda execution

resource "aws_iam_group_membership" "can_use_console" {
  name = "can-use-console"

  users = [
    aws_iam_user.gitlab_runner_terraform_lambda_user.name,
  ]

  group = aws_iam_group.can_use_console.name
}

resource "aws_iam_group" "can_use_console" {
  name = "can-use-console"
}

resource "aws_iam_group_policy_attachment" "can_use_console" {
  group      = aws_iam_group.can_use_console.name
  policy_arn = aws_iam_policy.can_use_console.arn
}

resource "aws_iam_policy" "can_use_console" {
  name   = "can_use_console"
  policy = data.aws_iam_policy_document.can_use_console.json
}

# deny all actions (except MFA configuration) as long as the user does not enable its MFA;
# from AWS doc: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html
# aws:username is an AWS policy variable so we do not want it
# to be interpolated by Terraform, so we use the $$ (to exclude the first $),
#
# here, "$${aws:username}" means "the user making the action", for instance:
#
# effect = "Allow"
# actions = [
#   "iam:ChangePassword",
#   ...
# ]
# resources = [
#   "arn:aws:iam::*:user/$${aws:username}"
# ]
#
# the code above allows an user to change "his own" password
data "aws_iam_policy_document" "can_use_console" {

  statement {
    sid    = "AllowViewAccountInfo"
    effect = "Allow"
    actions = [
      "iam:ListVirtualMFADevices",
      "iam:GetAccountSummary",
      "iam:GetAccountPasswordPolicy",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowManageOwnPasswords"
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:GetUser"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnAccessKeys"
    effect = "Allow"
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnSigningCertificates"
    effect = "Allow"
    actions = [
      "iam:DeleteSigningCertificate",
      "iam:ListSigningCertificates",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnSSHPublicKeys"
    effect = "Allow"
    actions = [
      "iam:DeleteSSHPublicKey",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnGitCredentials"
    effect = "Allow"
    actions = [
      "iam:CreateServiceSpecificCredential",
      "iam:DeleteServiceSpecificCredential",
      "iam:ListServiceSpecificCredentials",
      "iam:ResetServiceSpecificCredential",
      "iam:UpdateServiceSpecificCredential"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnVirtualMFADevice"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:mfa/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnUserMFA"
    effect = "Allow"
    actions = [
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "DenyAllExceptListedIfNoMFA"
    effect = "Deny"

    # we voluntarily do NOT grant permission to the user to change his own password until he has not set his MFA
    # AWS doc: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "sts:GetSessionToken"
    ]
    resources = ["*"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}
