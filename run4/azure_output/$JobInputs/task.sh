#!/bin/bash

export LC_ALL="C.UTF-8"
export LANG="C.UTF-8"

# Print arguments for debugging
echo "Task Arguments: $@"

# Azure Batch sets various environment variables that can be helpful
# https://docs.microsoft.com/en-us/azure/batch/batch-compute-node-environment-variables

# The ID of this job
echo "JobId = $AZ_BATCH_JOB_ID"
# The ID of this task
echo "TaskId = $AZ_BATCH_TASK_ID"
# The absolute path to the job prep working directory where any job prep resource files are downloaded.
echo "JobPrep Working Dir = $AZ_BATCH_JOB_PREP_WORKING_DIR"
# The absolute path to the this tasks working directory
echo "Task Working Dir = $AZ_BATCH_TASK_WORKING_DIR"
# The absolute path to a common shared directory
echo "Shared Dir = $AZ_BATCH_NODE_SHARED_DIR"

# Lets source the helper script in the job prep dir, it has helper functions
# to upload files to storage
. $AZ_BATCH_JOB_PREP_WORKING_DIR/taskhelpers.sh

#------------------------------------------------------------------------------#
# RUN TASK
#------------------------------------------------------------------------------#
STDOUT="stdout.log"
STDERR="stderr.log"


chmod +x run_repast.sh
./run_repast.sh > $STDOUT 2> $STDERR


# upload logs
upload_log_file $STDOUT
upload_log_file $STDERR

exit $?
