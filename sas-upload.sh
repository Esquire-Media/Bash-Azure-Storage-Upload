#!/bin/bash

# Define parameters
SOURCE_FILE_PATH=${1}
if [ -z "$SOURCE_FILE_PATH" ]; then
    echo "Source file path not specified"
    exit 1
fi
DESTINATION_FILE_PATH=${2}
if [ -z "$DESTINATION_FILE_PATH" ]; then
    echo "Destination file path not specified"
    exit 1
fi
AZURE_STORAGE_ACCOUNT=${3}
if [ -z "$AZURE_STORAGE_ACCOUNT" ]; then
    echo "Azure storage account not specified"
    exit 1
fi
SECURE_ACCESS_SIGNATURE=${4}
if [ -z "$SECURE_ACCESS_SIGNATURE" ]; then
    echo "Secure access signature not specified"
    exit 1
fi

# HTTP Request headers
HTTP_METHOD="PUT"
request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
x_ms_date_h="x-ms-date:$request_date"
x_ms_blob_type_h="x-ms-blob-type:BlockBlob"

# Build URI
URI="https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${DESTINATION_FILE_PATH}"

# Upload file
curl -X ${HTTP_METHOD} \
    -T ${SOURCE_FILE_PATH} \
    -H "$x_ms_date_h" \
    -H "$x_ms_blob_type_h" \
    -H "Content-Type: ${FILE_TYPE}" \
    ${URI}

if [ $? -eq 0 ]; then
    echo "File successfully uploaded."
    exit 0;
fi;
exit 1
