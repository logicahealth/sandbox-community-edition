#!/bin/bash

target_schema_count="13"
sleep_seconds=2

schema_count=$(mysql -uroot -ppassword -e "show databases;" | grep -E -c 'hspc_8_MasterDstu2Empty|hspc_8_MasterDstu2Smart|hspc_8_MasterR4Empty|hspc_8_MasterR5Empty|hspc_8_MasterR4Smart|hspc_8_MasterStu3Empty|hspc_8_MasterStu3Smart|hspc_8_hspc8|hspc_8_hspc9|hspc_8_hspc10|hspc_8_hspc11|oic|sandman')
sleep $sleep_seconds
if [ "$schema_count" -eq $target_schema_count ]
then
  exit 0
fi
exit 1
