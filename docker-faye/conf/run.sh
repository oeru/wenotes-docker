#!/bin/bash
# Bash hasn't been initialized yet so add path to composer manually.
#export PATH="$HOME/.composer/vendor/bin:$PATH"

# Run start script.
echo "*****Running run.sh"
CONF=/root/conf
WENOTES=/opt/wenotes
CWD=`pwd`
# Defines
WESERVER=https://kiwilightweight@bitbucket.org/wikieducator/wenotes-server.git
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

# next, get the Javascript code:
# get the repo
echo "moving to $WENOTES"
if [[ ! -d $WENOTES ]] ; then
    echo "creating directory $WENOTES"
    mkdir -p $WENOTES
fi
cd $WENOTES
echo "getting $WESERVER, putting it into server"
$GIT clone $WESERVER server


# next start various Javascript services
if [[ -f $CONF/faye.yml ]] ; then
    echo "moving to server"
    cd $WENOTES/server
    echo "installing Node.JS dependencies"
    $NPM install
    $CP $CONF/options.json options.json
    echo "starting pm2 to supervise scripts in $CONF/faye.yml"
    $PM2 start --no-daemon $CONF/faye.yml
    cd $WENOTES
fi

echo "returning to original dir: $CWD"
cd $CWD

echo "finished services"

if [[ -f $CONF/post-install.sh ]] ; then
  echo "Running: post-install.sh"
  source $CONF/post-install.sh
fi
echo "\n****** in run.sh ********\n"

# Run after-run scripts added by another containers.
if [[ -d $CONF/after-start ]] ; then
  FILES=$CONF/after-start/*
  for f in $FILES
  do
    echo "Attaching: $f"
    source $f
  done
fi