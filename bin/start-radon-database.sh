#!/bin/sh
set -uxe

os_version=$(grep -oPm1 'release\K\s+\w+' /etc/redhat-release)

crun="podman"

if [ $os_version -eq 7 ]; then
   crun=docker
fi

user=$(id -un)
container=$($crun ps -f name=radon-himan-regression-tests-container-$user --format "{{.Names}}")

if [ -n "$container" ]; then
  echo "container for himan-regression for user $user exists already"
  exit 1
fi

inject_data() {
  for f in $(ls etc/*.sql); do
    psql -q -f $f
  done
}

#function buildimage() {
#  echo "building database image"
#  cwd=$PWD
#  cd /tmp
#  rm -rf radon
#  git clone https://github.com/fmidev/radon
#  cd radon
#  log=$($crun build -t radon-himan-regression-tests . 2>&1)
#
#  if [ $? -ne 0 ]; then
#    echo "error building radon image"
#    echo $log
#    exit 1
#  fi
#
#  cd ..
#  rm -rf radon
#  cd $cwd
#}

image=$($crun images -f reference=radon-himan-regression-tests --format "{{.Repository}}" | head -1)

if [ -n "$image" ]; then
  echo "using local image $image"
else
  echo "using image from quay.io"
  image="quay.io/fmi/radon"
fi

echo -n "spinning up a database container "

$crun run \
	-d -p $RADON_PORT:5432 \
	-e POSTGRES_PASSWORD=$RADON_POSTGRES_PASSWORD \
	-e RADON_WETODB_PASSWORD=$RADON_WETODB_PASSWORD \
	-e RADON_RADON_ADMIN_PASSWORD=$RADON_RADON_ADMIN_PASSWORD \
	--rm --name=radon-himan-regression-tests-container-$user \
	$image > /dev/null

set +e

cnt=0

nc -z -w2 localhost $RADON_PORT

while [ $? -ne 0 ]; do
  if [ $cnt -eq 20 ]; then
    echo "timeout: database did not start"
    podman logs radon-himan-regression-tests-container-$user
    exit 1
  fi
  sleep 1
  cnt=$((cnt+1))
  nc -z -w2 localhost $RADON_PORT
done

export PGHOST=$RADON_HOSTNAME
export PGPORT=$RADON_PORT
export PGUSER=radon_admin
export PGPASSWORD=$RADON_RADON_ADMIN_PASSWORD
export PGDATABASE=radon

cnt=0

psql -Aqt -c "select now()" # > /dev/null 2>&1

while [ $? -ne 0 ]; do
  if [ $cnt -gt 30 ]; then
    echo "timeout: database did not initialize"
    podman logs radon-himan-regression-tests-container-$user
    exit 1
  fi
  #echo -n "."
  sleep 1
  cnt=$((cnt+1))
  psql -Aqt -c "select now()" # > /dev/null 2>&1
done

echo " database up"

inject_data
