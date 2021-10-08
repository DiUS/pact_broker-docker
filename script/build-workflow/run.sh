#!/bin/sh

set -euo >/dev/null

script_dir=$(cd "$(dirname $0)" && pwd)

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  echo ${DOCKER_HUB_TOKEN} | docker login --username ${DOCKER_HUB_USERNAME} --password-stdin
fi

. ${script_dir}/../release-workflow/set-env-vars.sh

${script_dir}/../release-workflow/docker-build.sh
${script_dir}/../scan.sh ${DOCKER_IMAGE_ORG_AND_NAME}:latest
