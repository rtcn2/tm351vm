#!/usr/bin/env bash

# This script is responsible for constructing the TM351 VM
# Child scripts are loaded using `source`
# This has the effect of making exported env vars available to them

#Set the base build directory to the one containing this script
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Python / pip installer
# (should really precede this with python package installation?)
#https://stackoverflow.com/questions/49836676/python-pip3-cannot-import-name-main
PIP="python3 -m pip"
export PIP

PIPNC="python3 -m pip install --no-cache-dir"
export PIPNC

#Keep track of build datetime
$BUILDDIR/version.sh

#Create users
TM351_USER=oustudent
TM351_UID=1351
TM351_GID=100
export TM351_USER TM351_UID TM351_GID

echo "Adding service user: $TM351_USER"
useradd -m -s /bin/bash -N -u $TM351_UID $TM351_USER
#Add oustudent user to sudo group
usermod -a -G sudo oustudent

TM351_USER_HOME="$(getent passwd $TM351_USER | cut -d: -f6)"

#Note: the user is used to run Jupyter notebook and OpenRefine services
echo "..user added"

#Make Jupyter and OpenRefine users same as the tm351 user
NB_USER=$TM351_USER
NB_GID=$TM351_GID
export NB_USER NB_GID

OPENREFINE_USER=$TM351_USER
OPENREFINE_GID=$TM351_GID
export OPENREFINE_USER OPENREFINE_GID
#...done users


#PRESERVE ENVT VARS
ENV_VARS=/etc/profile.d/course_env.sh

#Note - for env vars to be available to py kernel in Jupyter notebook
# they need to be defined in the Jupyter service definition file
# Use: `Environment=MYENVVAR=/my/value` as part of `[Service]` definition.

echo "" >> $ENV_VARS
echo "# Environemnt variables for OU course user" >> $ENV_VARS
echo "TM351_USER=$TM351_USER" >> $ENV_VARS
echo "TM351_UID=$TM351_UID" >> $ENV_VARS
echo "TM351_USER=$TM351_USER" >> $ENV_VARS
echo "TM351_GID=$TM351_GID" >> $ENV_VARS
echo "NB_USER=$NB_USER" >> $ENV_VARS
echo "NB_GID=$NB_GID" >> $ENV_VARS
echo "OPENREFINE_USER=$OPENREFINE_USER" >> $ENV_VARS
echo "OPENREFINE_GID=$OPENREFINE_GID" >> $ENV_VARS
echo "" >> $ENV_VARS


#END ENVT VARS


#Just in case
cp $BUILDDIR/files/fix-permissions /usr/local/bin/fix-permissions
chmod g+w /etc/passwd /etc/group
#End user definitions




#Build script for building machine
source $BUILDDIR/base/basepackages.sh
source $BUILDDIR/base/basepy.sh


#mongo causing lots of problems - so let's try to build it first
source $BUILDDIR/mongo/mongo.sh
# If we have managed to install it, try to seed the dbs...
if type mongo &> /dev/null; then
    source $BUILDDIR/mongo/simple/mongo_simple.sh
    #May need to run this for shards: fix-permissions /data
    source $BUILDDIR/mongo/sharded/mongo_cluster.sh
fi

#Jupyter space
source $BUILDDIR/jupyter-base/build_jupyter.sh
source $BUILDDIR/jupyter-custom/jupyter_nbextensions.sh
source $BUILDDIR/jupyter-custom/jupyter_styling.sh

#Bundler extensions
source $BUILDDIR/jupyter-custom/jupyter_extensions.sh

#OU custom packages and extensions
source $BUILDDIR/jupyter-custom/jupyter_ou_custom.sh
#source $BUILDDIR/jupyter-custom/jupyter_ou_tutor.sh
source $BUILDDIR/jupyter-custom/jupyter_lab.sh

source $BUILDDIR/jupyter-custom/jupyter_ou_test_nb.sh
source $BUILDDIR/jupyter-custom/jupyter_ou_trust.sh

source $BUILDDIR/pystack/build_tm351_stack.sh

source $BUILDDIR/openrefine/openrefine.sh

source $BUILDDIR/postgres/postgresql.sh


# Tidy up package lists
apt-get autoremove -y
apt-get clean -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*

# Zero out any free space to aid VM compression
#dd if=/dev/zero of=/EMPTY bs=1M
#rm -f /EMPTY

# Remove log files
#find /var/log -type f | while read f; do echo -ne '' > $f; done;
