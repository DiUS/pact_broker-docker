
# Dockerised Pact Broker

[![Build Status](https://travis-ci.org/DiUS/pact_broker-docker.svg)](https://travis-ci.org/DiUS/pact_broker-docker)

This repository contains a Dockerized [Pact Broker](https://github.com/pact-foundation/pact_broker). You can pull the `dius/pact-broker` image from [Dockerhub](https://hub.docker.com/r/dius/pact-broker/).

> A smaller and sexier Docker image has now been built in the [Pact Foundation](https://github.com/pact-foundation/pact-broker-docker) organization. The new image can be run without root permissions, and is only 98MB compressed! All environment variable configurations are the same, so you should just be able to switch from `dius/pact-broker` to `pactfoundation/pact-broker` and run with it - note that the default port has changed from 80 to 9292 though.

### Which one should I use?

Please read https://github.com/phusion/passenger/wiki/Puma-vs-Phusion-Passenger for information on which server will suit your needs best. The tl;dr is that if you want to run the docker image in a managed architecture which will make your application highly available (eg. ECS, Kubernetes) then use the `pactfoundation/pact-broker`. Puma will not restart itself if it crashes, so you will need external monitoring to ensure the Pact Broker stays available.

If you want to run the container as a standalone instance, then the `dius/pact-broker` image which uses Phusion Passenger may serve you better, as Passenger will restart any crashed processes.


> Note: On 12 May 2018, the format of the docker tag changed from `M.m.p-RELEASE` to `M.m.p.RELEASE` (where `M.m.p` is the semantic version of the underlying Pact Broker package) so that Dependabot can recognise when the version has been incremented.

## In a hurry?

If you want to try out a Pact Broker that can be accessed by all your teams, without having to fill in requisition forms and wait for 3 months, you can get a free trial at <a href="https://pactflow.io/?utm_source=github&utm_campaign=dius_pact_broker_docker">pactflow.io</a>. Built by a group of core Pact maintainers, Pactflow is a fork of the OSS Pact Broker with extra goodies like an improved UI, field level verification results and federated login. It's also fully supported, and that means when something goes wrong, *someone else* gets woken up in the middle of the afternoon to fix it...

## Prerequisites

* A running postgresql database and the ability to connect to it (see [POSTGRESQL.md][postgres]).
* If on Mac, you will need the `timeout` or `gtimeout` function. You can install `gtimeout` using `brew install coreutils`.

## Getting Started

1. [Install Docker](https://docs.docker.com/engine/installation/)

### Create the database

On an instance of Postgres version 10 or later, connect as a user with administrator privileges and run:

```
CREATE DATABASE pact_broker;
CREATE ROLE pact_broker WITH LOGIN PASSWORD 'CHANGE_ME';
GRANT ALL PRIVILEGES ON DATABASE pact_broker TO pact_broker;
```

### Configure the connection details

You can either set the `PACT_BROKER_DATABASE_URL` in the format `driver://username:password@host:port/database` (eg. `postgres://user1:pass1@myhost/mydb`) or, you can set the credentials individually using the following environment variables:

    * `PACT_BROKER_DATABASE_ADAPTER` (optional, defaults to 'postgres', see note below.)
    * `PACT_BROKER_DATABASE_USERNAME`
    * `PACT_BROKER_DATABASE_PASSWORD`
    * `PACT_BROKER_DATABASE_HOST`
    * `PACT_BROKER_DATABASE_NAME`
    * `PACT_BROKER_DATABASE_PORT` (optional, defaults to the default port for the specified adapter)

Adapter can be 'postgres' (recommended) or 'sqlite'. SQLite will work for spikes, but it is NOT supported as a production database.

For an SQLite database (only recommended for investigation/spikes, as it will be disposed of with the container unless you mount it from an external file system):

  * `PACT_BROKER_DATABASE_ADAPTER` (set to 'sqlite')
  * `PACT_BROKER_DATABASE_NAME` (arbitrary name eg. /tmp/pact_broker.sqlite)

You can additionally set:

    * `PACT_BROKER_DATABASE_SSLMODE` - optional, possible values: 'disable', 'allow', 'prefer', 'require', 'verify-ca', or 'verify-full' to choose how to treat SSL (only respected if using the postgres database adapter. See https://www.postgresql.org/docs/9.1/libpq-ssl.html for more information.)
    * `PACT_BROKER_SQL_LOG_LEVEL` - optional, defaults to debug. The level at which to log SQL statements.
    * `PACT_BROKER_SQL_LOG_WARN_DURATION` - optional, defaults to 5 seconds. Log the SQL for queries that take longer than this number of seconds.
    * `PACT_BROKER_DATABASE_MAX_CONNECTIONS` - optional, defaults to 4. The maximum size of the connection pool.
    * `PACT_BROKER_DATABASE_POOL_TIMEOUT` - optional, 5 seconds by default. The number of seconds to wait if a connection cannot be acquired before raising an error.

## Notes

* Use `-p 80:80` to start the docker image, as some of the Rack middleware gets confused by receiving requests for other ports and will return a 404 otherwise (port forwarding does not rewrite headers).
* On OSX, if you are not using Docker native, use `docker-machine ip $(docker-machine active)` to get the IP of the VirtualBox, and connect on port 80.
* The application makes use of the phusion passenger application server.
* Apart from creating a database no further preparation is required.

## Using basic auth

To enable basic auth, run your container with:

* `PACT_BROKER_BASIC_AUTH_USERNAME`
* `PACT_BROKER_BASIC_AUTH_PASSWORD`
* `PACT_BROKER_BASIC_AUTH_READ_ONLY_USERNAME`
* `PACT_BROKER_BASIC_AUTH_READ_ONLY_PASSWORD`

If you want to allow public read access (but still require credentials for writing), then omit setting the READ_ONLY credentials and set `PACT_BROKER_ALLOW_PUBLIC_READ=true`.

Developers should use the read only credentials on their local machines, and the CI should use the read/write credentials. This will ensure that pacts and verification results are only published from your CI.

Note that the [verification status badges][badges] are not protected by basic auth, so that you may embed them in README markdown.

## Heartbeat URL

If you are using the docker container within an AWS autoscaling group, and you need to make a heartbeat URL publicly available, set `PACT_BROKER_PUBLIC_HEARTBEAT=true`. No database connection will be made during the execution of this endpoint.

The heartbeat is available at `/diagnostic/status/heartbeat`.

## Using SSL

See the [Pact Broker configuration documentation][reverse-proxy].

## Setting the log level

Set the environment variable `PACT_BROKER_LOG_LEVEL` to one of `DEBUG`, `INFO`, `WARN`, `ERROR`, or `FATAL`.

## Webhook whitelists

* `PACT_BROKER_WEBHOOK_HOST_WHITELIST` - a space delimited list of hosts (eg. `github.com`), network ranges (eg. `10.2.3.41/24`, or regular expressions (eg. `/.*\\.foo\\.com$/`). Regular expressions should start and end with a `/` to differentiate them from Strings. Note that backslashes need to be escaped with a second backslash. Please read the [Webhook whitelists](https://docs.pact.io/pact_broker/configuration#webhook-whitelists) section of the Pact Broker configuration documentation to understand how the whitelist is used. Remember to use quotes around this value as it may have spaces in it.
* `PACT_BROKER_WEBHOOK_SCHEME_WHITELIST` - a space delimited list (eg. `http https`). Defaults to `https`.

## Other environment variables

* `PACT_BROKER_BASE_URL` - optional but *strongly recommended* when deploying the Pact Broker to production as it prevents some [security vulnerabilities](https://www.cloudflare.com/learning/dns/dns-cache-poisoning/). If you find that the URLs generated by the API are using an IP instead of a hostname, you can set this environment variable to force the desired base URL. Must include the port if it's a non-standard one. eg. `https://my-broker:9292`. This can also be used if you are mounting the Docker container so that it runs on a non root context eg. `https://my-company.com/pact-broker`. Not that this setting does not change where the application is mounted within the Docker container - it just changes the links.
* `PACT_BROKER_BASE_EQUALITY_ONLY_ON_CONTENT_THAT_AFFECTS_VERIFICATION_RESULTS` - `true` by default, may be set to `false`.
* `PACT_BROKER_ORDER_VERSIONS_BY_DATE` - `true` by default. Setting this to false is deprecated.
* `PACT_BROKER_DISABLE_SSL_VERIFICATION` - `false` by default, may be set to `true`. Disables SSL verification for webhook endpoints.

## General Pact Broker configuration and usage

Documentation for the Pact Broker application itself can be found in the Pact Broker [docs][pact-broker-docs].

## Running with Docker Compose

For a quick start with the Pact Broker and Postgres, we have an example
[Docker Compose][docker-compose] setup you can use:

1. Modify the `docker-compose.yml` file as required.
2. Run `docker-compose up` to get a running Pact Broker and a clean Postgres database

Now you can access your local broker:

```sh
curl -v http://localhost # you can visit in your browser too!

# SSL endpoint, note that URLs in response contain https:// protocol
curl -v -k https://localhost:8443
```

_NOTE: this image should be modified before using in Production, in particular, the use of hard-coded credentials_

## Running with Openshift

See [pact-broker-openshift](https://github.com/jaimeniswonger/pact-broker-openshift) for an example config file.

# Troubleshooting

See the [Troubleshooting][troubleshooting] page on the wiki.

[badges]: https://docs.pact.io/pact_broker/advanced_topics/provider_verification_badges
[troubleshooting]: https://github.com/pact-foundation/pact-broker-docker/wiki/Troubleshooting
[postgres]: https://github.com/DiUS/pact_broker-docker/blob/master/POSTGRESQL.md
[test-script]: https://github.com/DiUS/pact_broker-docker/blob/master/script/test.sh
[docker-compose]: https://github.com/DiUS/pact_broker-docker/blob/master/docker-compose.yml
[pact-broker-docs]: https://docs.pact.io/pact_broker/
[reverse-proxy]: https://docs.pact.io/pact_broker/configuration#running-the-broker-behind-a-reverse-proxy
