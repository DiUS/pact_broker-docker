require_relative "passenger_config"
require_relative "docker_configuration"
require "pact_broker"

app = PactBroker::App.new do | config |
  config.runtime_configuration = PactBroker.docker_configuration
  config.basic_auth_enabled = config.basic_auth_credentials_provided?
end

run app
