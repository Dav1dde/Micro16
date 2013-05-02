#!/bin/sh

kill $(ps ax | grep "SimpleHTTPServer 8000" | grep -v grep | awk '{ print $1 }')
python2 -m SimpleHTTPServer 8000 2>&1 > http.log&
./watch.sh 2>&1 > watch.log