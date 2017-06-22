From https://github.com/klaemo/docker-couchdb/tree/master/2.0.0

See https://github.com/klaemo/docker-couchdb for documentation

Starting CouchDB
================

docker run -d --name couchdb -v /home/dave/Docker/couchdb/data:/opt/couchdb/data oeru/couchdb


--Old--

Built via: docker build -t oeru/couchdb .

Building and Running Containers
-------------------------------

cd [path to wenotes-combined]

CouchDB
+++++++

Build: docker build -t oeru/couchdb docker-couchdb
Launch (replacing [admin password] and [bot password]):
  docker run --name couchdb -v /home/dave/Docker/wenotes/data:/opt/couchdb/data \
    -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=[admin password] \
    -e COUCHDB_BOT_USER=bot -e COUCHDB_BOT_PASSWORD=[bot password] \
    -d oeru/couchdb
    
Backup/Restore
++++++++++++++

Do a database dumps and restores using couchdb-backup.sh - from https://github.com/danielebailo/couchdb-dump

Faye
++++

Build: docker build -t oeru/faye docker-faye
Launch:
   docker run --name faye -v /home/dave/Docker/wenotes/faye:/opt/wenotes/server \
     -v /home/dave/Docker/wenotes/config/options.json:/opt/wenotes/options.json \
     -d oeru/faye

WENotes-tools
+++++++++++++

Build: docker build -t oeru/wenotes docker-wenotes-tools
Launch:
   docker run --name faye -v /home/dave/Docker/wenotes/wenotes:/opt/wenotes/wenotes \
      -v /home/dave/Docker/wenotes/config/options.json:/opt/wenotes/options.json \
      -d oeru/wenotes
