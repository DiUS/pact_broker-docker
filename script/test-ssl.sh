#!/usr/bin/env sh
export SSL_CERT_FILE=ssl/cacert.crt
curl -v https://localhost:8443

docker run --rm \
 -e SSL_CERT_FILE=ssl/cacert.crt \
  pactfoundation/pact-cli:latest \
  broker can-i-deploy \
  --pacticipant Foo \
  --latest \
  --broker-base-url https://localhost:8443
