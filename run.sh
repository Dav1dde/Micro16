#!/bin/sh

PID=$(ps ax | grep "SimpleHTTPServer 8000" | grep -v grep | awk '{ print $1 }')

if [ "$PID" != "" ]; then
    echo -n "Kill running SimpleHTTPServer on port 8000? [y/n]: "
    read KILL
    if [ "$KILL" == "y" -o "$KILL" == "yes" ]; then
        kill $PID
    else
        exit
    fi
fi

trap 'kill $(jobs -pr)' SIGINT SIGTERM EXIT

./watch.sh 2>&1 | tee watch.log &
python2 -m SimpleHTTPServer 8000 1>http.log 2>&1
