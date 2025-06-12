# lambda-gitlab-runner-for-terraform

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
