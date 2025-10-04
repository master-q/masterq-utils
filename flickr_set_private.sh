#!/bin/bash

if [ "$#" != "1" ]; then
    echo "Usage: $0 USER-NSID"
    exit 1
fi
USER_NSID=$1

for i in {50..1}; do
    echo +++ $i +++++++++
    ret=`flickcurl people.getPublicPhotos $USER_NSID 100 $i | grep "photo with URI" | awk '{ print $6 }'`
    for j in $ret; do
        echo $j
        flickcurl photos.setPerms $j no no no "" ""
    done
done
