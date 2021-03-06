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
ENV APT_SERVER http://ucmirror.canterbury.ac.nz/ubuntu
ENV APT_FILE sources.list
ENV UBUNTU_NAME xenial
# subdue the "Dialog" errors...
ENV DEBIAN_FRONTEND noninteractive
ENV COUCHDIR /opt/couchdb
#
# Add CouchDB user account
RUN groupadd -r couchdb && useradd -d $COUCHDIR -g couchdb couchdb

#
# add local mirror to reduce build time :)
RUN echo "deb $APT_SERVER ${UBUNTU_NAME} main universe" > /etc/apt/${APT_FILE}
RUN echo "deb $APT_SERVER ${UBUNTU_NAME}-updates main universe" >> /etc/apt/${APT_FILE}
RUN echo "deb $APT_SERVER ${UBUNTU_NAME}-security main universe" >> /etc/apt/${APT_FILE}
RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME} main universe" >> /etc/apt/${APT_FILE}
RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME}-updates main universe" >> /etc/apt/${APT_FILE}
RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME}-security main universe" >> /etc/apt/${APT_FILE}
# do one update and start installing...
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    haproxy \
    erlang-nox \
    erlang-reltool \
#    libicu52 \
    libmozjs185-1.0 \
    locales \
    openssl \
  && rm -rf /var/lib/apt/lists/*

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

ENV COUCHDB_VERSION 2.0.0

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
    libicu-dev \
    libmozjs185-dev \
  # install nodejs stack...
  && apt-get install -y nodejs \
  && npm install -g grunt-cli
  # set up pm2
  #RUN npm install -g pm2
  # Acquire CouchDB source code
  RUN cd /usr/src && mkdir couchdb \
  && curl -fSL https://dist.apache.org/repos/dist/release/couchdb/source/${COUCHDB_VERSION}/apache-couchdb-${COUCHDB_VERSION}.tar.gz -o couchdb.tar.gz \
  && tar -xzf couchdb.tar.gz -C couchdb --strip-components=1 \
  && cd couchdb \
  # Build the release and install into /opt
  && ./configure --disable-docs \
  && make release \
  && mv /usr/src/couchdb/rel/couchdb $COUCHDIR \
  # Cleanup build detritus
  && apt-get purge -y \
    binutils \
    build-essential \
    cpp \
    git \
    erlang-dev \
    libicu-dev \
    make \
    perl \
  && apt-get autoremove -y && apt-get clean \
 # && apt-get install -y libicu52 --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* /usr/lib/node_modules /usr/src/couchdb*

# Sprinkle couchdb configuration to the right places...
COPY couchdb/local.ini ${COUCHDIR}/etc/
COPY couchdb/vm.args ${COUCHDIR}/etc/
COPY couchdb/couchdb-init.sh /

# Setup directories and permissions
RUN chmod +x /couchdb-init.sh \
  && mkdir ${COUCHDIR}/data ${COUCHDIR}/etc/local.d ${COUCHDIR}/etc/default.d \
  && chown -R couchdb:couchdb ${COUCHDIR}

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

# expose relevant ports
WORKDIR ${COUCHDIR}
EXPOSE 5984 4369 9100
VOLUME ["${COUCHDIR}/data"]
ENTRYPOINT ["tini", "--", "/couchdb-init.sh"]
CMD ["/opt/couchdb/bin/couchdb"]
