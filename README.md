# lambda-gitlab-runner-for-terraform

## TODO

 * [ ] run gitlab-runner from the lambda (python runtime that calls shell script ?)
 * [ ] transfer Gitlab registration token and aws terraform credentials to the lambda (plain text for now)
 * [ ] use KMS to encrypt and decrypt the AWS credentials for terraform (encrypt on client, decrypt within the lambda)
 * [ ] provide a basic terraform that must be apply as root user to create a local user with the right to run the lambda, and provides the lambda user with all the privileges on the infrastructure
 * [ ] switch project to public
