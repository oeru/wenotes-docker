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
CRON=/etc/cron.d/wenotes

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

# set up Cron jobs...
echo "setting up cron jobs"
echo "# created by Docker and the OER Foundation" > $CRON
echo "4,24,44 * * * * root cd $WENOTES/tools/ && nice python gplus.py && nice python feeds.py && nice python groups.py" >> $CRON
echo "2,22,42 * * * * root cd $WENOTES/tools/ && nice python forums.py && nice python discourse.py --full " >> $CRON
chmod 0644 $CRON

# next start various Javascript services
if [[ -f $CONF/services.yml ]] ; then
    cd $WENOTES/tools
    echo "installing Node.JS dependencies"
    $NPM install
    #$CP $CONF/options.json.sample options.json
    echo "starting pm2 to supervise scripts in $CONF/services.yml"
    $PM2 start --no-daemon $CONF/services.yml
    #$PM2 start $CONF/services.yml
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
