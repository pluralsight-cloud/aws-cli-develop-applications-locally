#!/bin/bash

# A robust script to upload an image and log its metadata.

set -e
set -o pipefail

# --- Configuration ---
PROFILE="image-app-dev"
BUCKET_NAME="image-processor-app-imageprocessorbucket-wusx6rrp6ltx"
TABLE_NAME="image-metadata-table"

# --- Input Validation ---
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

IMAGE_FILE=$1

if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: File not found at '${IMAGE_FILE}'"
    exit 1
fi

# --- Script Logic ---
S3_URL="s3://${BUCKET_NAME}/${IMAGE_FILE}"

# 1. Upload the image file to S3
echo "Uploading ${IMAGE_FILE} to S3..."
aws s3 cp "${IMAGE_FILE}" "${S3_URL}" --profile "${PROFILE}"

# 2. Log metadata to DynamoDB
echo "Logging metadata to DynamoDB..."
aws dynamodb put-item \
    --table-name "${TABLE_NAME}" \
    --item "{\"ImageName\": {\"S\": \"${IMAGE_FILE}\"}, \"S3Url\": {\"S\": \"${S3_URL}\"}}" \
    --profile "${PROFILE}"

echo "✅ Successfully processed ${IMAGE_FILE}."
echo "   S3 URL: ${S3_URL}"