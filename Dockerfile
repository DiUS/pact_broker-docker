# ubuntu -- https://hub.docker.com/_/ubuntu/
# |==> phusion/baseimage -- https://github.com/phusion/baseimage-docker
#      |==> phusion/passenger-docker -- https://github.com/phusion/passenger-docker
#           |==> HERE
FROM phusion/passenger-ruby24:1.0.0

# Update OS as per https://github.com/phusion/passenger-docker#upgrading-the-operating-system-inside-the-container
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
RUN bash -lc 'rvm --default use ruby-2.4.5'

ENV APP_HOME=/home/app/pact_broker/
RUN rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default
COPY container /


COPY --chown=app pact_broker/ $APP_HOME/

RUN cd $APP_HOME && \
    gem install --no-document --minimal-deps bundler && \
    bundle install --deployment --without='development test' && \
    rm -rf vendor/bundle/ruby/2.4.0/cache/ /usr/local/rvm/rubies/ruby-2.4.4/lib/ruby/gems/2.4.0/cache

EXPOSE 8080

# Adding 'app' user to group 'root'
RUN set -ex && \
    adduser app root

# change file ownership to the group 'root' that should be acessible by user 'app'
RUN chgrp -R 0 /etc/container_environment /etc/container_environment.sh /etc/container_environment.json /etc/syslog-ng /etc/runit/runsvdir /var/log/nginx /var/lib/nginx && \
    chmod -R g+rwX /etc/container_environment /etc/container_environment.sh /etc/container_environment.json /etc/syslog-ng /etc/runit/runsvdir /var/log/nginx /var/lib/nginx
RUN chown -R app:app /etc/runit/runsvdir /var/run/

# Disabling syslog that needs to be run as root
RUN rm -rf /etc/my_init.d/10_syslog-ng.init
# Disabling cron that needs to be run as root
RUN touch /etc/service/cron/down && chmod +x /etc/service/cron/down

CMD ["/sbin/my_init"]

# This is the user 'app'
USER 9999