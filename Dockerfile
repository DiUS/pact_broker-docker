FROM phusion/passenger-ruby22:0.9.15

ENV APP_HOME=/home/app/pact_broker

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

ADD pact_broker/Gemfile $APP_HOME/
ADD pact_broker/Gemfile.lock $APP_HOME/
ADD customized_start $APP_HOME/

RUN chown -R app:app $APP_HOME
RUN su app -c "cd $APP_HOME && bundle install --deployment --without='development test'"

ADD pact_broker/ $APP_HOME/
RUN chown -R app:app $APP_HOME

CMD ["$APP_HOME/customize_webapp_conf_and_start.sh"]

EXPOSE 80 2020 3030 4040 5050 6060 7070
