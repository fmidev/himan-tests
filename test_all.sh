#!/bin/sh

set -u

if [ -z "$HIMAN" ]; then
  if [ "$1" = "release" ]; then 
      export HIMAN=$(pwd)/../himan-bin/build/release/himan
  else
    export HIMAN=$(pwd)/../himan-bin/build/debug/himan
  fi
fi

root=$PWD

. $root/bin/database-config.sh

LOGDIR=/tmp/$(id -un)

mkdir -p $LOGDIR

txtund=$(tput sgr 0 1)    # Underline
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtylw=$(tput setaf 3)    # Yellow
txtblu=$(tput setaf 4)    # Blue
txtpur=$(tput setaf 5)    # Purple
txtcyn=$(tput setaf 6)    # Cyan
txtwht=$(tput setaf 7)    # White
txtrst=$(tput sgr0)       # Text reset

function cleanup(){
    rm -rf $LOGDIR
    $root/bin/stop-radon-database.sh
}

function find_and_execute(){

    echo "Running $1"

    cd $root/$1 

    failed=0
    succeeded=0
    failed_tests=""

    for f in $(find . -maxdepth 2 -type f -name "*.sh" -print | sort); do
        dbase=$(dirname $f)
        sbase=$(basename $f)

        cd $root/$1/$dbase

        LOGFILE="$LOGDIR/$sbase.log"

        printf "%-20s %-25s %-50s " \
            $dbase \
            $sbase \
            " (log: $LOGFILE)" 

        RESULT=""

        starttime=$(date +%s%N)
        sh $sbase > $LOGFILE 2>&1
        ret=$?
        stoptime=$(date +%s%N)
 
        duration=$(echo "($stoptime - $starttime) / 1000000" | bc)
        if [ $ret -ne 0 ]; then
            RESULT="[${txtred}FAILED${txtrst}]"
        else
            RESULT="[${txtgrn}SUCCESS${txtrst}]"
        fi

        printf "%-25s  duration: ${duration}ms\n" $RESULT

        if [ $ret -ne 0 ]; then
            cat $LOGFILE
            failed=$(echo 1+$failed|bc)
            failed_tests="$failed_tests $f"
        else
            succeeded=$(echo 1+$succeeded|bc)
        fi
        rm -f $LOGFILE
    done

    total=$(echo $failed+$succeeded|bc)
    prcnt=$(echo "100*$succeeded/$total"|bc)

    echo "summary: $succeeded/$total tests succeeded ($prcnt %)"

    if [ $failed -ne 0 ]; then
        echo "failed tests were:"
        for f in $failed_tests; do
          echo " * $f"
        done
        cleanup
        exit 1
    fi
    cd $root
}

echo "Using himan executable from: $HIMAN"
echo "==============================================================="
sh $root/bin/check-for-gpu.sh
echo "==============================================================="

if [ $# -eq 1 ]; then
    if [ "$1" != "smoke-tests" ] && [ "$1" != "unit-tests" ] && [ "$1" != "integration-tests" ] && [ "$1" != "functional-tests" ] && [ "$1" != "performance-tests" ]; then
        echo "usage: $0 [ smoke-tests unit-tests integration-tests functional-tests performance-tests ]"
        exit 1
    fi

    if [ "$1" = "unit-tests" ] || [ "$1" = "performance-tests" ] ; then
        echo "Building $1"
        sh $root/$1/makesh > /dev/null
    fi

    if [ "$1" = "integration-tests" ] || [ "$1" = "functional-tests" ]; then
        set -e
        $root/bin/stop-radon-database.sh
        $root/bin/start-radon-database.sh
        set +e
    fi
    find_and_execute $1
else

    find_and_execute smoke-tests

    echo "Building unit-tests"
    sh $root/unit-tests/makesh > /dev/null
    find_and_execute unit-tests

    set -e
    $root/bin/stop-radon-database.sh
    $root/bin/start-radon-database.sh
    set +e

    if [ $? -ne 0 ]; then
       exit 1
    fi

    find_and_execute integration-tests
    find_and_execute functional-tests

    echo "Performance tests are disabled"
    
    # echo "Building performance-tests"
    # sh $root/performance-tests/makesh > /dev/null
    # find_and_execute performance-tests
fi

cleanup

echo "All clear -- hurraah!"

