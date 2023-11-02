#!/bin/sh
set -ue

os_version=$(grep -oPm1 'release\K\s+\w+' /etc/redhat-release)

crun="podman"

if [ $os_version -eq 7 ]; then
  crun=docker
fi

user=$(id -un)
container=$($crun ps -f name=radon-himan-regression-tests-container-$user --format "{{.Names}}")

if [ -z "$container" ]; then
  exit 0
fi

$crun stop $container
