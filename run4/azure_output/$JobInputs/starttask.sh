#!/bin/bash
set -e

export LC_ALL="C.UTF-8"
export LANG="C.UTF-8"


sudo apt-get update -y
sudo apt-get install -y build-essential libssl-dev libffi-dev libpython3-dev python3-dev python3-pip
# changed to --user from sudo
#pip3 install --upgrade pip
pip3 install --upgrade blobxfer==1.0.0
pip3 install --upgrade azure-batch


## my addition
sudo apt-get install -y openjdk-8-jdk openjdk-8-jre openjdk-8-jdk-headless openjdk-8-jre-headless
pip3 install argparse
