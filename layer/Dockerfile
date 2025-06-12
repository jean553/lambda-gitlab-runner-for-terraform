# Same AL version as Lambda execution environment AMI
# FROM amazonlinux:2017.03.1.20170812 as builder
FROM public.ecr.aws/lambda/python:3.13

RUN dnf update && \
    dnf install -y git hostname findutils

RUN dnf install -y wget && \
    wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner

RUN dnf install -y unzip && \
    wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform

COPY app.py ${LAMBDA_TASK_ROOT}

CMD ["app.lambda_handler"]

#RUN yum install -y git hostname

###### GitlabRunner base layer ######
#
####### Custom additional layers ######
#
## terraform
#RUN yum install -y unzip && \
#    wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && \
#    unzip terraform.zip && \
#    mv terraform /usr/local/bin/terraform && \
#    chmod +x /usr/local/bin/terraform
#
####### Create runtime image ######
##FROM lambci/lambda:provided as runtime
#FROM debian:bookworm-slim as runtime
#
#RUN apt update && apt install git hostname -y
#
#RUN mkdir -p /opt/bin
#
## Layer 1 - GitlabRunner
#COPY --from=builder /usr/local/bin/gitlab-runner /opt/bin/gitlab-runner
#
## Layer 2 - Terraform
#COPY --from=builder /usr/local/bin/terraform /opt/bin/terraform
#
#CMD ["sleep", "100"]
