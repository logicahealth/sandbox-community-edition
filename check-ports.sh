#!/usr/bin/env bash
#
# check to see if anything is running on required ports
#
for x in 3001 3306 8060 8070 8078 8079 8080 12000; do
  lsof -nP -iTCP -sTCP:LISTEN | grep $x
done
