#! /bin/sh

# set -e
# set -o pipefail

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

if [ "${S3_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${S3_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${BACKUP_FILE}" = "**None**" ]; then
  echo "You need to set the BACKUP_FILE environment variable."
  exit 1
fi

if [ "${S3_ENDPOINT}" == "**None**" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

echo "Creating dump of ${BACKUP_FILE} and streaming dump to $S3_BUCKET..."

DT=$(date +"%Y-%m-%d-%H%M%S-%Z")
echo $DT

if [ -n "$ENCRYPTED_DATA_KEY" ]; then
  if [ -n "$DATA_KEY" ]; then
    echo "$(date +"%Y-%m-%d-%H%M%S-%Z") have ENCRYPTED_DATA_KEY, upload to s3..."
    echo "$ENCRYPTED_DATA_KEY" | aws s3 cp - s3://$S3_BUCKET/$S3_PREFIX/$(date +"%Y")/$(date +"%m")/$(date +"%d")/${BACKUP_FILE}_$DT.ciphertext || exit 2

    echo "$(date +"%Y-%m-%d-%H%M%S-%Z") have DATA_KEY, pg_dump start..."
    gpg -c --batch --passphrase $DATA_KEY $BACKUP_FILE | aws s3 cp - s3://$S3_BUCKET/$S3_PREFIX/$(date +"%Y")/$(date +"%m")/$(date +"%d")/${BACKUP_FILE}_$DT.dump.gpg || exit 2

    echo "$(date +"%Y-%m-%d-%H%M%S-%Z") SQL backup uploaded successfully"
  else
    echo "backup failed!"
    exit 1
  fi
fi

exit 0
