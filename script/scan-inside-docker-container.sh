#!/usr/bin/env sh
set -eu

apt-get update -y && apt-get install -y wget
wget -q -O - https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin
trivy filesystem --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 --no-progress /
