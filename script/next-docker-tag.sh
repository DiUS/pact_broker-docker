set -e
DOCKER_IMAGE="dius/pact-broker"
# TODO pass this in
gem_version=$(docker run --rm -v ${PWD}/pact_broker/Gemfile.lock:/tmp/Gemfile.lock ruby:2.6.4-alpine ruby -e "puts File.read('/tmp/Gemfile.lock').match(/pact_broker \((.*)\)/)[1]")
existing_tags=$(wget -q https://registry.hub.docker.com/v1/repositories/${DOCKER_IMAGE}/tags -O - | jq -r .[].name)
existing_release_numbers_for_current_gem_version=$(echo "$existing_tags" | grep "${gem_version}-" | sed 's/'${gem_version}'-//g')
last_release_number=$(printf "0\n${existing_release_numbers_for_current_gem_version}" | sort -g | tail -1)
next_release_number=$[$last_release_number+1]
tag="${gem_version}-${next_release_number}"
echo $tag
