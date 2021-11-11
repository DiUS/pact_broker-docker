# ubuntu -- https://hub.docker.com/_/ubuntu/
# |==> phusion/baseimage -- https://github.com/phusion/baseimage-docker
#      |==> phusion/passenger-docker -- https://github.com/phusion/passenger-docker
#           |==> HERE
FROM phusion/passenger-ruby27:2.0.1

# Update OS as per https://github.com/phusion/passenger-docker#upgrading-the-operating-system-inside-the-container
# Broken update https://github.com/DiUS/pact_broker-docker/runs/3799650621?check_suite_focus=true#step:9:87
# RUN apt-get update && \
#    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
#    apt-get -qy autoremove && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN bash -lc 'rvm --default use ruby-2.7.4'

ENV APP_HOME=/home/app/pact_broker/
WORKDIR $APP_HOME

RUN rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default
COPY container /
#USER app

COPY --chown=app pact_broker/Gemfile $APP_HOME/Gemfile
COPY --chown=app pact_broker/Gemfile.lock $APP_HOME/Gemfile.lock
RUN cat Gemfile.lock | grep -A1 "BUNDLED WITH" | tail -n1 | awk '{print $1}' > BUNDLER_VERSION

RUN cd $APP_HOME && \
    gem install --no-document --minimal-deps bundler -v $(cat BUNDLER_VERSION) && \
    bundle config set deployment 'true' && \
    bundle install --without='development test' && \
    rm -rf vendor/bundle/ruby/2.4.0/cache/ /usr/local/rvm/rubies/ruby-2.4.4/lib/ruby/gems/2.4.0/cache

COPY --chown=app pact_broker/ $APP_HOME/

EXPOSE 80
CMD ["/sbin/my_init"]
