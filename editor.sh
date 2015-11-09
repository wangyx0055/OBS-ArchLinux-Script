#!/bin/sh
PKGNAME=`cat $1|grep -oP '(?<=name=")[A-Za-z0-9-_.]+'`
sed -i "s/<title></<title>${PKGNAME}</g" $1