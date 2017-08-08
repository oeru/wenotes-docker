#!/bin/bash
# Bash hasn't been initialized yet so add path to composer manually.
#export PATH="$HOME/.composer/vendor/bin:$PATH"

# Run start script.
echo "*****Running run.sh"
CONF=/root/conf
WENOTES=/opt/wenotes/server
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
            echo "copying configuration..."
            cp -a $CONF .
            echo "installing Node.JS dependencies"
            $NPM install
            # if a phantom options.json *directory* has been created, remove it
            if [[ -d options.json ]] ; then
                echo "*** phantom options.json directory created - removing"
                rmdir options.json
                if [[ -d options.json ]] ; then 
                    echo "*** *** failed to remove the directory... "
                fi
            fi
            # if the options.json file's not there, link it from $WENOTES
            if [[ ! -f options.json ]] ; then 
                echo "no options.json found in $WENOTES/server..."
                if [[ -f ../options.json ]] ; then 
                    echo "found options.json in .., linking here"
                    ln -sf ../options.json .
                else
                    echo "couldn't find options.json! This isn't going to work without manual intervention"
                fi 
            fi 
            echo "starting pm2 to supervise scripts in $WENOTES/server/conf/faye.yml"
            $PM2 start --no-daemon conf/faye.yml
            cd $WENOTES
        else
            echo "***looks like clone of wenotes-server failed - it's not in $WENOTES/server..."
        fi
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
