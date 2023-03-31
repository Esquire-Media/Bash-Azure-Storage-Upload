#!/bin/bash

# Usage
# ./azure-blob-upload-using-sas.sh {SOURCE FILE PATH} {AZURE STORAGE ACCOUNT NAME} {DESTINATION FILE PATH} {SIGNATURE} {SIGNATURE VALIDITY START} {SIGNATURE VALIDITY END}
# ./azure-blob-upload-using-sas.sh /path/to/file.txt uniquename path/to/blob/file.txt AbCd/Ef/GhIjKlMnOp/QrStUvWxY/z01234/56789/== 2022-01-01T00:00:00Z 2022-02-01T00:00:00Z

# Function to encode URL parameters
urlencode() {
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    LC_COLLATE=$old_lc_collate
}

# Define parameters
SOURCE_FILE_PATH="${1}"
if [ -z "$SOURCE_FILE_PATH" ]; then
    echo "Source file path not specified"
    exit 1
fi
AZURE_STORAGE_ACCOUNT="${2}"
if [ -z "$AZURE_STORAGE_ACCOUNT" ]; then
    echo "Azure storage account not specified"
    exit 1
fi
DESTINATION_FILE_PATH="${3}"
if [ -z "$DESTINATION_FILE_PATH" ]; then
    echo "Destination file path not specified"
    exit 1
fi
SECURE_ACCESS_SIGNATURE=$(urlencode "${4}")
if [ -z "$SECURE_ACCESS_SIGNATURE" ]; then
    echo "Secure access signature not specified"
    exit 1
fi
SIGNATURE_START=$(urlencode "${5}")
if [ -z "$SIGNATURE_START" ]; then
    echo "Secure access signature start datetime not specified"
    exit 1
fi
SIGNATURE_END=$(urlencode "${6}")
if [ -z "$SIGNATURE_END" ]; then
    echo "Secure access signature end datetime not specified"
    exit 1
fi

# HTTP Request headers
request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
x_ms_date_h="x-ms-date:$request_date"
x_ms_blob_type_h="x-ms-blob-type:BlockBlob"

# Build URI
SAS="sv=2021-10-04&st=${SIGNATURE_START}&se=${SIGNATURE_END}&sr=c&sp=acwl&sig=${SECURE_ACCESS_SIGNATURE}"
URI="https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${DESTINATION_FILE_PATH}?${SAS}"

# Upload file
curl \
    -X PUT \
    -T ${SOURCE_FILE_PATH} \
    -H "$x_ms_date_h" \
    -H "$x_ms_blob_type_h" \
    -H "Content-Type: ${FILE_TYPE}" \
    ${URI}

if [ $? -eq 0 ]; then
    exit 0;
fi;
exit 1
