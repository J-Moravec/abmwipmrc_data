#!/bin/bash
set -e

function download_output {
    # Key to remote HDD
    KEY="/9TvU+JTNaadULoXjBMLb/O+fTciOYygh08EQVPWLgwguinHSZ0mKsoPc/dqbVwzUK8yBsVYLvwreZwTTzTflA=="

    TARGETDIR=$1
    REMOTEDIR=$2

    blobxfer download \
        --local-path "${TARGETDIR}" \
        --remote-path "${REMOTEDIR}" \
        --storage-account stormacs1 \
        --storage-account-key "$KEY" \
        --progress-bar
    }


function extract_runs {
    SOURCE=$1
    TARGET=$2
    for i in $(ls -d [0-9]* | sort -V); do
        cp $SOURCE/$i/\$TaskOutput/*.gz $TARGET
        done
    }


OUTPUTDIR="azure_output"
TARGETDIR="source"
mkdir -p $OUTPUTDIR
mkdir -p $TARGETDIR


download_output $OUTPUTDIR "job-${1}"
extract_runs $OUTPUTDIR $TARGETDIR
cp $OUTPUTDIR \$JobInputs/unrolledParamFile.txt ./model_params.txt

#rm -r $OUTPUTDIR
