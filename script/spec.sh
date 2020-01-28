#!/usr/bin/env sh

source script/docker-functions

docker_build_package_base
run_on_package_base "bundle exec rake spec"
