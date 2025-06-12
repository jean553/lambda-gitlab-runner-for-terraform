import json
import subprocess
import os
import time
import boto3

def lambda_handler(event, context):

    # p = run(["ls"], capture_output=True)

    env_vars = os.environ.copy()
    env_vars["HOME"] = "/tmp"

    p = subprocess.Popen([
        "gitlab-runner",
        "register",
        "--non-interactive",
        "--url",
        "https://gitlab.com",
        "--registration-token",
        "xxx",
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
