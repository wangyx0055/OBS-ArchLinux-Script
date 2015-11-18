#!/bin/sh
basedir=$(cd `dirname $0`;pwd)

ps -ef | grep update | grep -v grep && exit 0

cd $basedir/../
ls|grep -v _SCRIPT|while read line
do
  cd $basedir/../$line
  osc up
done
