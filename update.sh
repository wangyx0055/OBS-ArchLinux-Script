#!/bin/sh
basedir=$(cd `dirname $0`;pwd)

cd $basedir/../
ls|grep -v _SCRIPT|while read line
do
  cd $basedir/../$line
  osc up
done