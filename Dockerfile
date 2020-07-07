FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache python3 py-pip jq gnupg && \
    pip install --upgrade pip && \
    pip install awscli && \
    apk del py-pip && \
    rm -rf /var/cache/apk/*

ENV BACKUP_FILE = **None** \
S3_ACCESS_KEY_ID = **None** \
S3_SECRET_ACCESS_KEY = **None** \
S3_BUCKET = **None** \
S3_REGION = "ap-east-1" \
S3_PREFIX = "backup" \
S3_ENDPOINT = **None** \
S3_S3V4 = "yes"

ADD backup.sh backup.sh
