#!/bin/bash
# Build pact_broker image from docker file and connect to the application
set -e

trap 'echo "FAILED"; exit 1' ERR

docker build -t=dius/pact_broker .

# Stop and remove any running broker_app container instances before updating
docker ps -a | grep broker_app && \
  echo "Stopping and removing running instance of pact broker container" && \
  docker stop broker_app && \
  docker rm broker_app

if [ "$(uname)" == "Darwin" ]; then
  test_ip=$(boot2docker ip)
else
  test_ip='localhost'
fi

docker run --name broker_app \
  -e PACT_BROKER_DATABASE_USERNAME=$PACT_BROKER_DATABASE_USERNAME \
  -e PACT_BROKER_DATABASE_PASSWORD=$PACT_BROKER_DATABASE_PASSWORD \
  -e PACT_BROKER_DATABASE_HOST=$PACT_BROKER_DATABASE_HOST \
  -e PACT_BROKER_DATABASE_NAME=$PACT_BROKER_DATABASE_NAME \
  -e PACT_BROKER_PORT=$PACT_BROKER_PORT
  -d -p $PACT_BROKER_PORT:$PACT_BROKER_PORT dius/pact_broker

sleep 5

container_id=$(docker ps -f name=broker_app | tail -1 | awk '{print $1}')
echo 'Checking that server can be connected to from within Docker container'
docker exec ${container_id} curl -v http://localhost:$PACT_BROKER_PORT
echo 'Checking that server can be connected to from outside Docker container'
curl http://${test_ip}:$PACT_BROKER_PORT
echo ''
response_code=$(curl -s -o /dev/null -w "%{http_code}" http://${test_ip}:$PACT_BROKER_PORT)

[[ "${response_code}" != '200' ]] && echo 'Error retrieving index from oustide Docker container' && exit 1
[[ "${response_code}" == '200' ]] && echo 'Successfully retrieved index from outside Docker container'
