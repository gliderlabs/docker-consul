#!/bin/bash

set -eo pipefail
[[ "$TRACE" ]] && set -x || :

debug() {
  [[ "$DEBUG" ]] && echo "-----> $*" 1>&2
}

consul_version() {
  sed -n "s/ENV CONSUL_VERSION //p" Dockerfile
}

next_version() {
  debug "new version will be calculated ..."
  local oldVersion=$(consul_version)
  debug "oldVersion: $oldVersion"
  echo ${oldVersion%.*}.$((${oldVersion##*.} + 1))
}

update_dockerfile() {
  declare ver=${1:? required}
  
  local sha=$(curl -Ls https://releases.hashicorp.com/consul/${ver}/consul_${ver}_SHA256SUMS | sed -n "s/ .*linux_amd64.*//p")
  debug "sha=$sha"

  sed -i "s/\(ENV CONSUL_VERSION\) .*/\1 $newVersion/;s/\(ENV CONSUL_SHA256\) .*/\1 $sha/" Dockerfile
}

main() {
    declare desc="Updates Dockerfile url/sha for the provided version, or calculates next patch version if called without params"
    declare newVersion=${1:-$(next_version)}
    
    debug "newVersion=$newVersion"
    update_dockerfile $newVersion
    git diff
    echo "=====> Now you can run: git commit -am 'Upgrade Consul to $newVersion'"
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || :
