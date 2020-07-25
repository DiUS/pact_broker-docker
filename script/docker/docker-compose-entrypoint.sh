#!/bin/sh

echo "Sleeping 5 seconds to ensure the postgres database is up and running. TODO: change this to poll"
sleep 3
/sbin/my_init
