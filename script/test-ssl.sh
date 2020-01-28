#!/usr/bin/env sh
export SSL_CERT_FILE=ssl/cacert.crt
curl -v https://localhost:8443

# THIS IS NOT GOING TO WORK because it needs a proper host name,
# not localhost - this will try and connect to the localhost of the
# pact-cli docker container

docker run --rm \
 -e SSL_CERT_FILE=/tmp/cacert.crt \
 -v ${PWD}/ssl/cacert.crt:/tmp/cacert.crt \
  pactfoundation/pact-cli:latest \
  broker can-i-deploy \
  --pacticipant Foo \
  --latest \
  --broker-base-url https://pact_broker:8443
