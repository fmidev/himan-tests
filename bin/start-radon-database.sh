#!/bin/sh
set -ue

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

set +u

if [ -n "$RADON_ACTIVE_CONTAINER" ]; then
  echo "using running radon container $RADON_ACTIVE_CONTAINER"

else
  set -u
  image=$($crun images -f reference=radon-himan-regression-tests --format "{{.Repository}}" | head -1)

  if [ -n "$image" ]; then
    echo "using local image $image"
  else
    echo "using image from quay.io"
    image="quay.io/fmi/radon"
  fi

  echo "spinning up a database container "

  $crun run \
	-d -p $RADON_PORT:5432 \
	-e POSTGRES_PASSWORD=$RADON_POSTGRES_PASSWORD \
	-e RADON_WETODB_PASSWORD=$RADON_WETODB_PASSWORD \
	-e RADON_RADON_ADMIN_PASSWORD=$RADON_RADON_ADMIN_PASSWORD \
	--rm --name=radon-himan-regression-tests-container-$user \
	$image > /dev/null

fi

set -u
set +e

cnt=0

nc -z -w2 localhost $RADON_PORT

while [ $? -ne 0 ]; do
  sleep 1
  nc -z -w2 localhost $RADON_PORT
  cnt=$(expr $cnt + 1)
  if [ $cnt -gt 10 ]; then
    echo "unable to connect to radon container"
    exit 1
  fi
done

echo "radon container started"

export PGHOST=$RADON_HOSTNAME
export PGPORT=$RADON_PORT
export PGUSER=radon_admin
export PGPASSWORD=$RADON_RADON_ADMIN_PASSWORD
export PGDATABASE=radon

echo -n "waiting for database to initialize "

cnt=0

psql -Aqt -c "select now()" > /dev/null 2>&1

while [ $? -ne 0 ]; do
  cnt=$(expr $cnt + 1)
  if [ $cnt -gt 10 ]; then
    echo "unable to login to radon container"
    exit 1
  fi

  echo -n "."
  sleep 1
  psql -Aqt -c "select now()" > /dev/null 2>&1
done

echo " database up"

inject_data
