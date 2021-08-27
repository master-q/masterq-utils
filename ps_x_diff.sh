#!/bin/bash

# NAME: ps_x_diff.sh
# DESCRIPTION: Monitor user process's CPU assignment changing per second
# LICENSE: public domain

function do_ps() {
    ps x -o comm,pid,ppid,psr,args|grep -v "ps x"|grep -v "sort"|grep -v "grep"|grep -v "ps_x_diff.sh"|grep -v ]$|sort -n -k 4
}

rm -f ps_x_diff.prev.tmp ps_x_diff.now.tmp
trap "rm -f ps_x_diff.prev.tmp ps_x_diff.now.tmp; exit 1" 0

do_ps > ps_x_diff.prev.tmp
SEC=0

while :; do
    sleep 1
    SEC=`expr $SEC + 1`
    echo ===== $SEC second
    do_ps > ps_x_diff.now.tmp
    diff ps_x_diff.prev.tmp ps_x_diff.now.tmp
    mv ps_x_diff.now.tmp ps_x_diff.prev.tmp
done
