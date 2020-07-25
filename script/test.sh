#!/bin/sh

set -e

cleanup() {
  docker-compose -f docker-compose-tests.yml rm -fv  || true
}
trap cleanup EXIT

cleanup

docker-compose -f docker-compose-tests.yml up --build --abort-on-container-exit --exit-code-from sut
cleanup

export PACT_BROKER_BASIC_AUTH_USERNAME=foo
export PACT_BROKER_BASIC_AUTH_PASSWORD=bar
export PACT_BROKER_PUBLIC_HEARTBEAT=true
docker-compose -f docker-compose-tests.yml up --build --abort-on-container-exit --exit-code-from sut
