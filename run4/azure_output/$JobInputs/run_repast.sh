#!/bin/bash
set -u # exits when some variable is unset
set -e # exits when encountering error

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
# TASK SPECIFIC SETTING
#------------------------------------------------------------------------------#
ID=$AZ_BATCH_TASK_ID # ID goes from 0 to N-1 where N is total tasks

echo "My ID is: ${ID}"

TOTALRUNS=4500 # for testing prupose otherwise wc -l $input_file
RUNSPERTASK=10
TOTALTASKS=450 # manually calculated: ceil totalruns/runspertask
REPEATS=50

# set limits
RUNSFROM=$((1+ID*RUNSPERTASK))
RUNSTO=$((RUNSPERTASK+ID*RUNSPERTASK))


if [ $(($ID + 1)) -eq $TOTALTASKS ]; then
    RUNSTO=$TOTALRUNS
fi

echo "Running from: ${RUNSFROM}"
echo "Running to: ${RUNSTO}"

#------------------------------------------------------------------------------#
# RUN SPECIFIC SETTING
#------------------------------------------------------------------------------#

DIR=$PWD
MODELDIR=simple_model_fixed
OUTPUTDIR=output
MODDIR=modified
ZIPDIR=zipped

PARAMFILE=unrolledParamFile.txt
SINGLEPARAMFILE=singleParamFile.txt

#JAVALIBS="../lib/*"
BATCHPARAMS="../scenario.rs/batch_params.xml"
SCENARIO="../scenario.rs"

#------------------------------------------------------------------------------#
# TASK CODE
#------------------------------------------------------------------------------#

# You can call any script you want here - just make sure it and
# any dependencies are in the 'task' folder.

# file "MessageCenter.log4j.properties" must be one level above this folder
# i.e., if path is FOLDER,  "MessageCenter.log4j.properties" must be in ../FOLDER

echo "Copying and unpacking model files to working directory"
cp ${AZ_BATCH_JOB_PREP_WORKING_DIR}/${MODELDIR}.tar.gz \
   ${AZ_BATCH_TASK_WORKING_DIR}/${MODELDIR}.tar.gz
mkdir ${MODELDIR}
tar -zxf ${MODELDIR}.tar.gz -C ${MODELDIR}

cp $PARAMFILE $MODELDIR/$PARAMFILE
cd $MODELDIR

mkdir $OUTPUTDIR
mkdir $MODDIR
mkdir $ZIPDIR

# outer cycle, runs parameters:
for i in $(seq $RUNSFROM $RUNSTO); do
    echo "Run parameter line $i"
    # make param file
    sed -n ${i}p $PARAMFILE > $SINGLEPARAMFILE

    cd $OUTPUTDIR

    # inner cycle, cycle through all repeats, runs model
    for j in $(seq 1 $REPEATS); do
    echo "Run replication $j for parameter line $i"
        java -cp "../lib/*" repast.simphony.batch.InstanceRunner \
            -pxml $BATCHPARAMS \
            -scenario $SCENARIO \
            -id 1 \
            -pinput ../$SINGLEPARAMFILE

        # add repeat and rename
        python3 $DIR/make_columns.py --input ModelOutput.txt --run $i --repeat $j > column_file.txt
        cut --complement -f1 -d"," ModelOutput.txt > ModelOutput.cut
        paste -d"," column_file.txt ModelOutput.cut > ../${MODDIR}/run_${i}_repeat_${j}.txt
        rm ModelOutput.txt ModelOutput.cut column_file.txt
    done
    cd ..
done


echo "Constructing output."
####################
# Construct output #
####################
# get header: -- header is in all files, but when we concatenate them
#             -- we need only the first one
head -n 1 ${MODDIR}/run_${i}_repeat_${j}.txt > header.txt

# Get all files without output
tail -q -n +2 ${MODDIR}/*.txt > output.txt

# connects with header
cat header.txt output.txt > ${ZIPDIR}/runs_${RUNSFROM}_${RUNSTO}.txt

# gzip
gzip ${ZIPDIR}/runs_${RUNSFROM}_${RUNSTO}.txt \
    -c > ${ZIPDIR}/runs_${RUNSFROM}_${RUNSTO}.gz
upload_task_output ${ZIPDIR}/runs_${RUNSFROM}_${RUNSTO}.gz

exit $?
