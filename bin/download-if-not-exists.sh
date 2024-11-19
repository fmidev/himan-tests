set -u

data=$1

if [ ! -f "$data" ]; then
  echo "data $data not present, copying it from lake.fmi.fi"
  set -ex
  url=https://lake.fmi.fi/himan-tests-source-data/$data
  s3_size=$(curl -sI $url | grep -i Content-Length | awk '{print $2}' | tr -cd '[:print:]')

  curl --retry 1 --keepalive-time 2 $url -o $data

  file_size=$(stat -c %s $data)

  if [ $? -ne 0 ] || [ $file_size -ne $s3_size ] ; then
    # retry
    echo "Download failed, retrying"
    rm -f $data
    curl --retry 1 --keepalive-time 2 $url -o $data
  fi
fi
