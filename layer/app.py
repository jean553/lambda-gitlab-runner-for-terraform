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

    # Terraform will look for Scaleway keys in a variable names "AWS ..."
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

    time.sleep(120)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
