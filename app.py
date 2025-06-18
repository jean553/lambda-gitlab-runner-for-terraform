import json
import subprocess
import os
import time
import boto3

def lambda_handler(event, context):

    # gathering all the environment variables is required here,
    # so that we can pass it to the processes we start later
    # through the subprocess.Popen() call;
    # otherwise, binaries would not be found when called
    os_env_vars = os.environ.copy()

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=os_env_vars["AWS_USED_REGION"]
    )

    response = client.get_secret_value(
        SecretId='credentials-for-gitlab-runner'
    )
    secret = response['SecretString']

    secret_values = json.loads(secret)

    env_vars = secret_values.copy()
    env_vars.update(os_env_vars)

    env_vars["HOME"] = "/tmp"

    # Terraform will look for Scaleway keys in a variable named "AWS ..."
    #
    # - when updating an AWS infrastructure, the lambda has a profile with IAM permission attached that has full privileges,
    # - when updating a Scaleway infrastructure, the lambda will use Scaleway credentials in AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
    #
    # IMPORTANT: we do NOT need to set manually the variables AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN
    # when running the lambda function with Terraform that modifies the AWS infrastructure;
    # this is because AWS automatically grants the required privileges to the lambda by automatically setting these variables;
    # the granted privileges are based on the role attached to the Lambda
    # Official AWS documentation: https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html#configuration-envvars-runtime
    if event["TARGET_CLOUD_PLATFORM"] == "scaleway":
        env_vars["AWS_ACCESS_KEY_ID"] = env_vars["SCW_ACCESS_KEY"]
        env_vars["AWS_SECRET_ACCESS_KEY"] = env_vars["SCW_SECRET_KEY"]

    p = subprocess.Popen([
        "gitlab-runner",
        "register",
        "--non-interactive",
        "--url",
        "https://gitlab.com",
        "--registration-token",
        env_vars["GITLAB_RUNNER_REGISTRATION_TOKEN"],
        "--executor",
        "shell",
        "--builds-dir=/tmp/builds",
        "--cache-dir=/tmp/cache"
    ], env=env_vars)

    time.sleep(30)

    pa = subprocess.Popen([
        "gitlab-runner",
        "run"
    ], env=env_vars)

    # this parameter must be set accordingly with the lambda expected timeout;
    # for instance, a run of 150 seconds should result to a timeout of ~200 seconds
    # (so that the first steps of the lambda are also included in the total time
    # without making the lambda timeout)
    time.sleep(500)

    return {'statusCode': 200}
