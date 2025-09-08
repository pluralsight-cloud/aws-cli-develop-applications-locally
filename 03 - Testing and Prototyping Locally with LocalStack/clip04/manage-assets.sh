#!/bin/bash

# A utility script to manage application assets in S3.

set -e
set -o pipefail

# --- Configuration ---
PROFILE="image-app-dev"
BUCKET_NAME="image-processor-app-imageprocessorbucket-local"
ENDPOINT_URL="http://localhost:4566"

# --- Main Logic ---
COMMAND=$1

case $COMMAND in
  list)
    echo "Listing objects in bucket: ${BUCKET_NAME}"
    aws s3 ls "s3://${BUCKET_NAME}/" --profile "${PROFILE}" --endpoint-url "${ENDPOINT_URL}"
    ;;

  fetch)
    FILENAME=$2
    if [ -z "$FILENAME" ]; then
      echo "Error: Please specify a filename to fetch."
      echo "Usage: $0 fetch <filename>"
      exit 1
    fi

    echo "Checking for '${FILENAME}' in bucket..."
    
    # Use aws s3api head-object to check for existence.
    # It exits with a non-zero status if the object is not found.
    if aws s3api head-object --bucket "${BUCKET_NAME}" --key "${FILENAME}" --profile "${PROFILE}" --endpoint-url "${ENDPOINT_URL}" >/dev/null 2>&1; then
      echo "File found. Downloading '${FILENAME}'..."
      aws s3 cp "s3://${BUCKET_NAME}/${FILENAME}" "./${FILENAME}" --profile "${PROFILE}" --endpoint-url "${ENDPOINT_URL}"
      echo "✅ Download complete."
    else
      echo "Error: File '${FILENAME}' not found in bucket."
      exit 1
    fi
    ;;

  *)
    echo "Usage: $0 {list|fetch}"
    exit 1
    ;;
esac