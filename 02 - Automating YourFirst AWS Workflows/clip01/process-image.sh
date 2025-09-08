#!/bin/bash

# A simple script to upload an image and log its metadata.

# --- Configuration ---
PROFILE="image-app-dev"
BUCKET_NAME="image-processor-app-imageprocessorbucket-wusx6rrp6ltx"
TABLE_NAME="image-metadata-table"

# --- Script Logic ---
# Get the filename from the first command-line argument.
IMAGE_FILE=$1
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

echo "Processing complete."