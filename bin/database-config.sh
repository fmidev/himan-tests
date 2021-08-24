export RADON_HOSTNAME=localhost
# if running inside container (container-in-container),
# set port to 5432
set +u
if [ -z "$container" ] && [ ! -f "/.dockerenv" ]; then
  export RADON_PORT=$(echo 10000+$(id -u)|bc)
else
  export RADON_PORT=5432
fi
set -u
export RADON_WETODB_PASSWORD=regression
export RADON_RADON_ADMIN_PASSWORD=$RADON_WETODB_PASSWORD
export RADON_POSTGRES_PASSWORD=$RADON_WETODB_PASSWORD
