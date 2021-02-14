#!/bin/sh

set -euo >/dev/null

script_dir=$(cd "$(dirname $0)" && pwd)

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  ${script_dir}/../release-workflow/docker-login.sh
fi

export DOCKER_IMAGE_ORG_AND_NAME=dius/pact-broker

${script_dir}/../release-workflow/docker-build.sh
${script_dir}/../scan.sh ${DOCKER_IMAGE_ORG_AND_NAME}:latest
