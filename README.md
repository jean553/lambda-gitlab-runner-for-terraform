# lambda-gitlab-runner-for-terraform

Update your infrastructure from a AWS Lambda, running as a Gitlab runner, ready for CI/CD, executing Terraform commands in an isolated and safe environment.

## Table of content

 * Why this project ?
 * How it works ?
 * Installation
    * Build the Lambda runtime
    * Create resources
    * Setup secrets
    * Configure Gitlab project
    * Run the script

## Why this project

Running Terraform commands is a critical step of your development process. Those commands are meant to modify your infrastructure, including your different environments, especially your production.

Such actions should not be runnable directly from developers, SREs or sysops workstations. Terraform commands usually require a very high level of privileges, due to their nature of impacting the whole infrastructure; for security reasons, granting individual contributors with such high privileges on their own machine is something we do want to avoid. Instead, a single minimalistic, isolated and secured computing unit should handle that specific task.

Main Terraform actions should only be performed when infrastructure changes are requested, hence why we can fairly assume the main Terraform commands (`plan`, `apply`...) to be part of CI/CD pipelines, along with proposed Merge Requests.

Finally, Gitlab Runner could run on a dedicated lonesome EC2 instance, however, that would require to run a machine all the time, whilest computing resource is only required during the execution of the Terraform command. For cost reasons, we prefer to turn to Lambda functions to host our Gitlab Runner service instead.

This project combines:
 * Terraform,
 * AWS Lambda,
 * AWS Secrets Manager,
 * Gitlab CI/CD runner

## How it works ?

 * setup privileged credentials in AWS Secrets Manager to be used by the Gitlab Runner (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `GITLAB_RUNNER_REGISTRATION_TOKEN` ... etc ...), 
 * run a local script (with limited privileges) that starts the Gitlab runner lambda and that keeps it alive,
 * push your Terraform changes and create Merge Requests, Terraform commands will be run into the Lambda function,
 * verify and apply your changes directly through Gitlab CI pipelines

## Installation

You need enough privileges to go through the installation step. Simplest way is to use your account **root credentials**. However, keep in mind this is usually a bad practice, and that you should disable access afterwards.

```sh
```

-----

The installation process covers the following steps:
 * creation of the `gitlab-runner-terraform-setup-user` (using the root account),
 * creation of the resources and deployment of the Lambda image (using the `gitlab-runner-terraform-setup-user`),

### Creation of the setup user

This is the only step that must be performed with **root credentials**.

### Build the Lambda runtime

```sh
docker build -t gitlab-runner/gitlab-runner-terraform-lambda .
```

```sh

```

----

## TODO

 * [ ] run gitlab-runner from the lambda (python runtime that calls shell script ?)
 * [ ] transfer Gitlab registration token and aws terraform credentials to the lambda (plain text for now)
 * [ ] use KMS to encrypt and decrypt the AWS credentials for terraform (encrypt on client, decrypt within the lambda)
 * [ ] provide a basic terraform that must be apply as root user to create a local user with the right to run the lambda, and provides the lambda user with all the privileges on the infrastructure
 * [ ] add information about the minimum privileges required for the user that pushes the lambda image on ECR and run the lambda, so that even to do so, no root credentials are required
 * [ ] ensure the image on the ECR is private; the ecr password is generated through aws command only if the person has the required rights (through his aws credentials)
 * [ ] give privileges to the lambda:
    - through IAM permissions for AWS infra,
    - through credentials forwarding for scaleway (KMS or other way to access them securily); can be a specific user also (not root)
 * [ ] switch project to public

 * [ ] put everyhting in terraform (secret manager, policies, role, lambda...)
