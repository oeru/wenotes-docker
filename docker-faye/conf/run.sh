#!/bin/bash
# Bash hasn't been initialized yet so add path to composer manually.
#export PATH="$HOME/.composer/vendor/bin:$PATH"

# Run start script.
echo "***** Running run.sh *****"
ROOTCONF=/root/conf
CONF=/opt/conf
WENOTES=/opt/wenotes
CWD=`pwd`
# Defines
WESERVER=https://kiwilightweight@bitbucket.org/wikieducator/wenotes-server.git
GIT=`which git`
NPM=`which npm`
PM2=`which pm2`
CP=`which cp`

#echo "CWD=$CWD, GIT=$GIT"

# Run before-run scripts added by another containers.
if [[ -d $ROOTCONF/before-start ]] ; then
  FILES=$ROOTCONF/before-start/*
  for f in $FILES
  do
    echo "Attaching: $f"
    source $f
  done
fi

if [[ -f $ROOTCONF/pre-install.sh ]] ; then
  echo "Running: pre-install.sh"
  source $ROOTCONF/pre-install.sh
fi

echo "first arg is $1"

if [ 'a' == 'b' ] ; then
    echo "a is b"
else
    echo "a isn't b"
    echo "first arg is $1"
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
if [[ ! -d '.git' ]] ; then
    echo "getting $WESERVER, putting it into server"
    cd /tmp
    $GIT clone $WESERVER server
    cp -a /tmp/server/.??* $WENOTES/server
    cp -a /tmp/server/* $WENOTES/server
else
    echo "server already in place..."
fi

# sort out options.json, which should be on the local file system's conf/ directory
if [[ -f $CONF/options.json ]] ; then
    echo "checking if we should copy options.json from $CONF to $WENOTES"
    if [[ -f $WENOTES/options.json ]] ; then
        echo "not overwriting existing"
    else
        echo "copying options.json from $CONF to $WENOTES"
        cp $CONF/options.json $WENOTES
    fi
fi

# next start various Javascript services
if [[ -f $ROOTCONF/faye.yml ]] ; then
    echo "moving to server"
    if [[ -d $WENOTES/server ]] ; then
        cd $WENOTES/server
        echo "installing Node.JS dependencies"
        $NPM install
        # this will be provided on the local filesystem, linked via a volume...
        # $CP $ROOTCONF/options.json options.json
        echo "starting pm2 to supervise scripts in $WENOTES/server/conf/faye.yml"
        $PM2 start --no-daemon $ROOTCONF/faye.yml
        #$PM2 start $ROOTCONF/faye.yml
        cd $WENOTES
    else
        echo "***looks like clone of wenotes-server failed - it's not in $WENOTES/server..."
    fi
fi

echo "returning to original dir: $CWD"
cd $CWD


echo "finished services"

if [[ -f $ROOTCONF/post-install.sh ]] ; then
    echo "Running: post-install.sh"
    source $ROOTCONF/post-install.sh
fi
echo "\n****** in run.sh ********\n"

# Run after-run scripts added by another containers.
if [[ -d $ROOTCONF/after-start ]] ; then
    FILES=$ROOTCONF/after-start/*
    for f in $FILES
    do
        echo "Attaching: $f"
        source $f
    done
fi
exit 1
