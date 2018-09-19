#!/bin/bash
echo "runnning jobprep.sh"

export LC_ALL="C.UTF-8"
export LANG="C.UTF-8"

# A job preparation task is a job specific action that you want executed on a VM
# once before any tasks are executed.  This is where you can setup job specific 
# environment details like apps, moving files around etc.

# Dump the env to show the environment variables available to this script
env > environment_variables.txt

STORAGE_ACCOUNT_KEY="/9TvU+JTNaadULoXjBMLb/O+fTciOYygh08EQVPWLgwguinHSZ0mKsoPc/dqbVwzUK8yBsVYLvwreZwTTzTflA=="

# Upload the file(s) to storage so they are persisted
# The storage account and container variables are set in the python client
# that starts the job
blobxfer upload \
    --local-path environment_variables.txt \
    --remote-path $OUTPUT_CONTAINER \
    --storage-account $STORAGE_ACCOUNT \
    --storage-account-key $STORAGE_ACCOUNT_KEY


## my thing:
blobxfer download \
    --local-path $AZ_BATCH_JOB_PREP_WORKING_DIR/ \
    --remote-path jmoravec/simple_model_fixed.tar.gz \
    --storage-account $STORAGE_ACCOUNT \
    --storage-account-key $STORAGE_ACCOUNT_KEY


exit 0
