FROM oeru/wenotes-base

MAINTAINER Dave Lane dave@oerfoundation.org - @lightweight and https://tech.oeru.org

# cron is already installed in the base image

# set up cron tasks
RUN set -ex \
    && { \
        echo "# created by Docker and the OER Foundation"; \
        echo "MAILTO=webmaster@oerfoundation.org"; \
        echo "LOG=/var/log/cron.log"; \
        echo "WEDIR=/opt/wenotes/tools"; \
        echo "PY=/usr/bin/python"; \
        echo '8,18,28,38,48,58 * * * * root cd $WEDIR && nice $PY bookmarks.py && nice $PY medium.py'; \
        echo '6,16,26,36,46,56 * * * * root cd $WEDIR && nice $PY mastodon.py && nice $PY hypothesis.py'; \
        echo '4,14,24,34,44,54 * * * * root cd $WEDIR && nice $PY gplus.py && nice $PY feeds.py && nice $PY groups.py'; \
        echo '2,12,22,32,42,52 * * * * root cd $WEDIR && nice $PY forums.py && nice $PY discourse.py --full'; \
        echo '*/1 * * * * root echo "Cron ran at $(date)" >> $LOG'; \
   } | tee /etc/cron.d/wenotes-cron

RUN chmod 0644 /etc/cron.d/wenotes-cron

RUN touch 0644 /var/log/cron.log

CMD cron && tail -f /var/log/cron.log
