#!/bin/bash

set -o nounset
set -o errexit

NUM=50
[ "${1-}" != "" ] && NUM="$1"
 

L=$( ( condor_q -l | grep -e '^Requirements = ' -e '^GlobalJobId = ' -e '^$' | grep -C 1 '^Requirements = .*HAS_EGSNRC [^a-zA-Z]* true' | grep '^GlobalJobId' ; condor_status -l | grep -i -e '^HAS_ELDONOISE = ' -e '^GlobalJobId = ' -e '^$' | grep '^HAS_ELDONOISE = true' -C 1 | grep '^GlobalJobId = '; ) | sort | uniq -c | grep '^\s*2\s' | sed -e 's/#[0-9]*"//' -e 's/.*#//' | tail -n $NUM )

condor_hold $L

sleep 150

condor_release $L



