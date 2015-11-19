#!/bin/sh
basedir=$(cd `dirname $0`;pwd)

if [ `ps -e | grep -c $(basename $0)` -gt 2 ]; then exit 0; fi

cd $basedir/../
ls|grep -v _SCRIPT|while read line
do
  cd $basedir/../$line
  osc up
done
