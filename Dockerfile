FROM public.ecr.aws/lambda/python:3.13

RUN dnf update && \
    dnf install -y git hostname findutils diffutils

RUN dnf install -y wget && \
    wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner

RUN dnf install -y unzip && \
    wget -O terraform.zip https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform

COPY app.py ${LAMBDA_TASK_ROOT}

CMD ["app.lambda_handler"]
