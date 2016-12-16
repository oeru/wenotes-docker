#!/bin/bash
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

set -e

if [ "$1" = '/usr/bin/couchdb' ]; then

	if [ ! -z "$NODENAME" ] && ! grep "couchdb@" /etc/couchdb/vm.args; then
		echo "-name couchdb@$NODENAME" >> /etc/couchdb/vm.args
	fi

    DOCKERFILE=/etc/couchdb/local.d/docker.ini

    printf "[chttpd]\nbind_address = any\n" > $DOCKERFILE

	if [ "$COUCHDB_USER" ] && [ "$COUCHDB_PASSWORD" ]; then
		# Create admin
        echo "Setting admin access details"
		printf "[admins]\n%s = %s\n" "$COUCHDB_USER" "$COUCHDB_PASSWORD" >> $DOCKERFILE
        if [ "$COUCHDB_BOT_USER" ] && [ "$COUCHDB_BOT_PASSWORD" ]; then
            printf "%s = %s\n" "$COUCHDB_BOT_USER" "$COUCHDB_BOT_PASSWORD" >> $DOCKERFILE
        fi
        if [ "$COUCHDB_PROXYSECRET" ]; then
            echo "Setting a proxy secret"
            printf "[couch_httpd_auth\]\nrequire_valid_user = true\nsecret = %s\n" "$COUCHDB_PROXYSECRET" >> $DOCKERFILE
        else
            printf "[couch_httpd_auth\]\nrequire_valid_user = true\n" >> $DOCKERFILE
        fi
		chown couchdb:couchdb $DOCKERFILE
	fi

	# if we don't find an [admins] section followed by a non-comment, display a warning
	if ! grep -Pzoqr '\[admins\]\n[^;]\w+' /etc/couchdb/local.d/*.ini; then
		# The - option suppresses leading tabs but *not* spaces. :)
		cat >&2 <<-'EOWARN'
			****************************************************
			WARNING: CouchDB is running in Admin Party mode.
			         This will allow anyone with access to the
			         CouchDB port to access your database. In
			         Docker's default configuration, this is
			         effectively any other container on the same
			         system.
			         Use "-e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password"
			         to set it in "docker run".
			****************************************************
		EOWARN
	fi


	exec gosu couchdb "$@"
fi

exec "$@"
