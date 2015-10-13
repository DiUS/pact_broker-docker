#!/bin/bash

cd /home/app/pact_broker/
export SEDBIN=/bin/sed
$SEDBIN "s/<broker_port>/${PACT_BROKER_PORT}/" webapp.conf > container/etc/nginx/sites-enabled/webapp.conf
cp -r container/etc/* /etc/
/sbin/my_init