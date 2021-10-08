#!/bin/sh

echo "sleeping 5"
sleep 5
/pact/entrypoint.sh broker publish /pacts --consumer-app-version 1 --tag "feat/foo" --verbose
