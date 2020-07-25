#!/bin/bash

cp ../pact-broker-docker/spec/docker_configuration_spec.rb spec/docker_configuration_spec.rb
cp ../pact-broker-docker/spec/basic_auth_spec.rb spec/basic_auth_spec.rb
cp ../pact-broker-docker/pact_broker/database_connection.rb pact_broker/database_connection.rb
cp ../pact-broker-docker/pact_broker/pact_broker_resource_access_policy.rb pact_broker/pact_broker_resource_access_policy.rb
cp ../pact-broker-docker/pact_broker/basic_auth.rb pact_broker/basic_auth.rb
cp ../pact-broker-docker/pact_broker/resource_access_rules.rb pact_broker/resource_access_rules.rb
cp ../pact-broker-docker/pact_broker/logger.rb pact_broker/logger.rb
cp ../pact-broker-docker/pact_broker/docker_configuration.rb pact_broker/docker_configuration.rb
rm -rf script/release-workflow/
cp -R ../pact-broker-docker/script/release-workflow script/release-workflow
rm -rf script/update-gems-workflow
cp -R ../pact-broker-docker/script/update-gems-workflow/ script/update-gems-workflow
cp ../pact-broker-docker/.github/workflows/release_image.yml .github/workflows/release_image.yml
cp ../pact-broker-docker/.github/workflows/update_gems.yml .github/workflows/update_gems.yml
cp ../pact-broker-docker/script/trigger-release.sh script/trigger-release.sh
cp ../pact-broker-docker/script/dispatch-gem-released.sh script/dispatch-gem-released.sh
cp ../pact-broker-docker/docker-compose-tests.yml docker-compose-tests.yml
cp ../pact-broker-docker/docker-compose-test-different-env-var-names.yml docker-compose-test-different-env-var-names.yml
cp ../pact-broker-docker/script/test.sh script/test.sh
cp ../pact-broker-docker/script/docker/docker-compose-entrypoint.sh script/docker/docker-compose-entrypoint.sh
cp -R ../pact-broker-docker/test test