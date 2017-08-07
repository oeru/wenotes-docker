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

echo "arg 1 = $1"

if [ "$1" = 'faye' ]; then

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
        if [[ -d $WENOTES/server ]] ; then
          cd $WENOTES/server
          echo "installing Node.JS dependencies"
          $NPM install
          # this will be provided on the local filesystem, linked via a volume...
          # $CP $CONF/options.json options.json
          echo "starting pm2 to supervise scripts in $WENOTES/server/conf/faye.yml"
          $PM2 start --no-daemon conf/faye.yml
          #$PM2 start $CONF/faye.yml
          cd $WENOTES
        else
          echo "***looks like clone of wenotes-server failed - it's not in $WENOTES/server..."
    fi

    echo "returning to original dir: $CWD"
    cd $CWD
else
    echo "no-op!"
fi

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
