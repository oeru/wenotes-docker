# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

FROM ubuntu:xenial

MAINTAINER Dave Lane dave@oerfoundation.org
# (adapted from work by Clemens Stolle klaemo@apache.org)

# Purpose - run a full WENotes stack including the faye message server,
# the wenotes service with couchdb, and various external processing tools
#
# The aim: to make a manageable fully functional dev environment which
# fosters remote API-ification for registering new blog users,
# updating details for session validation, and possibly integrating Mautic...
#ENV APT_SERVER http://ucmirror.canterbury.ac.nz/ubuntu
#ENV APT_FILE sources.list
#ENV UBUNTU_NAME xenial
# subdue the "Dialog" errors...
ENV DEBIAN_FRONTEND noninteractive
#
# Add CouchDB user account
RUN groupadd -r couchdb && useradd -d /opt/couchdb -g couchdb couchdb

#
# add local mirror to reduce build time :)
#RUN echo "deb $APT_SERVER ${UBUNTU_NAME} main universe" > /etc/apt/${APT_FILE}
#RUN echo "deb $APT_SERVER ${UBUNTU_NAME}-updates main universe" >> /etc/apt/${APT_FILE}
#RUN echo "deb $APT_SERVER ${UBUNTU_NAME}-security main universe" >> /etc/apt/${APT_FILE}
#RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME} main universe" >> /etc/apt/${APT_FILE}
#RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME}-updates main universe" >> /etc/apt/${APT_FILE}
#RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME}-security main universe" >> /etc/apt/${APT_FILE}
# do one update and start installing...
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    cron \
    curl \
    erlang-nox \
    erlang-reltool \
    git \
    haproxy \
    less \
    libmozjs185-1.0 \
    locales \
    openssl \
    python \
    python-bs4 \
    python-chardet \
    python-couchdb \
    python-feedparser \
    python-html5lib \
    python-httplib2 \
    python-lxml \
    python-lxml \
    python-pip \
    python-requests \
    python-urllib3

# grab gosu for easy step-down from root and tini for signal handling
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
  && curl -o /usr/local/bin/tini -fSL "https://github.com/krallin/tini/releases/download/v0.9.0/tini" \
  && curl -o /usr/local/bin/tini.asc -fSL "https://github.com/krallin/tini/releases/download/v0.9.0/tini.asc" \
  && gpg --verify /usr/local/bin/tini.asc \
  && rm /usr/local/bin/tini.asc \
  && chmod +x /usr/local/bin/tini

# install cron and msmtp for outgoing email
RUN apt-get install -y cron msmtp rsyslog

# install useful tools
RUN apt-get install -y less net-tools vim

# install Node.JS repos and do another update...
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && echo 'deb https://deb.nodesource.com/node_4.x trusty main' > /etc/apt/sources.list.d/nodesource.list \
  && echo 'deb-src https://deb.nodesource.com/node_4.x trusty main' >> /etc/apt/sources.list.d/nodesource.list \
  && apt-get update -y -qq
# Download dev dependencies
RUN apt-get install -y --no-install-recommends \
  build-essential \
  erlang-dev \
  libcurl4-openssl-dev \
  libmozjs185-dev \
  # install nodejs stack...
  && apt-get install -y nodejs \
  && npm install -g grunt-cli
# set up pm2
RUN npm install -g pm2
# Cleanup build detritus
RUN apt-get autoremove -y && apt-get clean

# Set up the language variables
ENV LANG en_NZ.UTF-8
ENV LANGUAGE en_NZ.UTF-8
ENV LC_ALL en_NZ.UTF-8
# Compile the language spec
RUN locale-gen $LANG
#
# Some final exports to get the environment right...
RUN echo "export VISIBLE=now" >> /etc/profile \
  && echo "export TERM=xterm" >> /etc/bash.bashrc

# set up the various scripts we need to run on the container
# after it's built...
COPY ./conf /root/conf/
#Prepare the main install script
RUN chmod u+x /root/conf/*.sh

# expose relevant volumes
VOLUME ["/opt/wenotes/tools", "/opt/wenotes/logs", "/opt/wenotes/tools/options.json", "/opt/wenotes/tools/msmtprc"]

# First, say we're doing it
RUN echo "running run.sh - /root/conf/run.sh"
# Actually do it when we run the container.
ENTRYPOINT ["tini", "--", "/root/conf/run.sh"]
CMD ["wenotes"]
