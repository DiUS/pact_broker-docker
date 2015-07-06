FROM phusion/passenger-ruby22:latest

ENV HOME /root
CMD ["/sbin/my_init"]
RUN rm -f /etc/service/nginx/down

RUN rm /etc/nginx/sites-enabled/default
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
ADD pactbroker-env.conf /etc/nginx/main.d/pactbroker-env.conf

RUN gem install bundler

RUN mkdir -p /home/app/pact_broker
RUN mkdir /home/app/pact_broker/public
RUN mkdir /home/app/pact_broker/tmp

WORKDIR /home/app/pact_broker
ADD config.ru config.ru
ADD Gemfile Gemfile
RUN bundle install
RUN chown -R app:app /home/app/pact_broker

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
