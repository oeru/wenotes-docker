#!/bin/bash
# Bash hasn't been initialized yet so add path to composer manually.
#export PATH="$HOME/.composer/vendor/bin:$PATH"

# Run start script.
echo "*****Running run.sh"
CONF=/root/conf
COUCH=/root
WENOTES=/opt/wenotes
CWD=`pwd`
# Defines
WETOOLS=https://kiwilightweight@bitbucket.org/wikieducator/wenotes-tools.git
GIT=`which git`
NPM=`which npm`
PM2=`which pm2`
CP=`which cp`

echo "CWD=$CWD, GIT=$GIT"

# Run before-run scripts added by another containers.
if [[ -d $CONF/before-start ]] ; then
  FILES=$CONF/before-start/*
  for f in $FILES
  do
    echo "Attaching: $f"
    source $f
  done
fi

if [[ -f $CONF/pre-install.sh ]] ; then
  echo "Running: pre-install.sh"
  source $CONF/pre-install.sh
fi

echo "starting services"

# remove default msmtprc
if [[ -f /opt/wenotes/tools/msmtprc ]] ; then
    echo "moving our msmtprc to /etc and /etc/msmtprc to /etc/msmtprc.default"
    mv /etc/msmtprc /etc/msmtprc.default
    cp /opt/wenotes/tools/msmtprc /etc/msmtprc
fi

# next, get the Javascript code:
if [[ -f $WENOTES/tools/options.json ]] ; then
    echo "we already have a set of tools, continuing"
else 
    # get the repo
    echo "moving to $WENOTES"
    # get the repo
    echo "getting $WETOOLS, putting it into server"
    cd /tmp
    $GIT clone $WETOOLS tools
    cd $WENOTES
    if [[ -d $WENOTES/tools ]] ; then
        echo "$WENOTES/tools already exists - moving /tmp/tools/* there..."
        cp -a /tmp/tools/* $WENOTES/tools
    else
        echo "creating $WENOTES/tools"
        mv /tmp/tools $WENOTES
    fi
    # set up options.json

    echo "returning to original dir: $CWD"
    cd $CWD
fi

echo "finished services"

if [[ -f $CONF/post-install.sh ]] ; then
  echo "Running: post-install.sh"
  source $CONF/post-install.sh
fi
echo "****** in run.sh ********"

# Run after-run scripts added by another containers.
if [[ -d $CONF/after-start ]] ; then
  FILES=$CONF/after-start/*
  for f in $FILES
  do
    echo "Attaching: $f"
    source $f
  done
fi

