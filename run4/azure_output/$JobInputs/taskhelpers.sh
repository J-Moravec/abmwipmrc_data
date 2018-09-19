#!/bin/bash

export LC_ALL="C.UTF-8"
export LANG="C.UTF-8"

function upload_file {
    file_path="$1"
    blob="$2"
    blobxfer upload \
        --local-path "$file_path" \
        --remote-path $OUTPUT_CONTAINER/"$blob" \
        --storage-account $STORAGE_ACCOUNT \
        --sas $OUTPUT_CONTAINER_SAS \
        --rename
#    blobxfer $STORAGE_ACCOUNT $OUTPUT_CONTAINER "$file_path" \
#        --saskey $OUTPUT_CONTAINER_SAS \
#        --remoteresource "$blob"
}

function upload_log_file {
    file_path=$1
    file_name=$(basename $file_path)
    blob="$AZ_BATCH_TASK_ID/\$TaskLog/$file_name"
    upload_file "$file_path" "$blob"
}

function upload_job_output {
    file_path=$1
    file_name=$(basename $file_path)
    blob="\$JobOutput/$file_name"
    upload_file "$file_path" "$blob"
}

function upload_task_output {
    file_path=$1
    file_name=$(basename $file_path)
    blob="$AZ_BATCH_TASK_ID/\$TaskOutput/$file_name"
    upload_file "$file_path" "$blob"
}
