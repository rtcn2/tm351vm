#!/bin/bash

user=$1

git clone https://github.com/innovationOUtside/tm351vm --depth 1 --branch=master ~$user/tm351vm
cd ~$user/tm351vm/build/

token='myImpossiblyHardToGuessToken'

#add NotebookApp token
# jupyter-base/services/jupyter.service
#--NotebookApp.token=myImpossiblyHardToGuessToken
sed -i -E "s/--NotebookApp\.token=/--NotebookApp.token=$token/" jupyter-base/services/jupyter.service

#stop build of mongo sharded demo
#monolithic_build.sh
# source $BUILDDIR/mong/sharded/mongo_cluster.sh
sed -i "s/source \$BUILDDIR\/mongo\/sharded\/mongo_cluster\.sh/# source \$BUILDDIR\/mongo\/sharded\/mongo_cluster.sh/" monolithic_build.sh

sudo ./monolithic_build.sh

#output urls for services

