#!/bin/sh

set -euo >/dev/null

script_dir=$(cd "$(dirname $0)" && pwd)

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  echo ${DOCKER_HUB_TOKEN} | docker login --username ${DOCKER_HUB_USERNAME} --password-stdin
fi

. ${script_dir}/../release-workflow/set-env-vars.sh

${script_dir}/../release-workflow/docker-build.sh
# Disabling due to https://github.com/DiUS/pact_broker-docker/runs/3834356643?check_suite_focus=true#step:4:285
# ${script_dir}/../scan.sh ${DOCKER_IMAGE_ORG_AND_NAME}:latest
