#!/bin/bash

echo "*** This script break your CDN URL (staticflickr.com)!"
exit 1

if [ "$#" != "1" ]; then
    echo "Usage: $0 USERNAME"
    exit 1
fi
NSID=`flickcurl people.findByUsername $1 | grep -oP 'NSID\s+\K\S+(?=\s)'`
echo $NSID

for i in {50..1}; do
    echo +++ $i +++++++++
    ret=`flickcurl people.getPublicPhotos $NSID 100 $i | grep "photo with URI" | awk '{ print $6 }'`
    for j in $ret; do
        echo $j
        flickcurl photos.setPerms $j no no no "" ""
    done
done
