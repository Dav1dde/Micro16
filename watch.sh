#!/bin/sh

inotifywait -m ./src -r | while read -r dir event name; do
    #python2 ./build.py
    if [ "$event" == "MODIFY" -o "$event" == "MOVED_TO" ]; then
        echo $name | grep "\.coffee$" > /dev/null
        if [ $? -eq 0 ]; then
            python2 build.py
        fi
    fi
done