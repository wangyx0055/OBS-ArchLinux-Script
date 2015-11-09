#!/bin/zsh
basedir=$(cd `dirname $0`;pwd)
REPO='home:mazdlc:missing'
PREFIX=""
SRC_REPO=community
PKGBUILD_PREFIX="https://projects.archlinux.org/svntogit/${SRC_REPO}.git/plain/trunk/PKGBUILD?h=packages/"
for line in "$@"
do
    cd $basedir/../$REPO
    export EDITOR="${basedir}/editor.sh"
    [ -d ${PREFIX}$line ] || osc meta pkg -e ${REPO} ${PREFIX}$line
    cd $basedir/../
    osc co ${REPO}/${PREFIX}$line
    true
done

#osc up

for line in "$@"
do
    function merge { local IFS="$1"; shift; echo "$*"; }
    cd $basedir/../$REPO/${PREFIX}$line || continue
    cp $basedir/missing_service ./_service
    cp $basedir/missing_PKGBUILD ./PKGBUILD
    pkgname=""
    pkgver=""
    depends=""
    provides=""
    conflicts=""
    eval "`curl -s "${PKGBUILD_PREFIX}${PREFIX}$line"|grep -vP "^options="`"
    echo $pkgname $pkgver $depends
    _depends=`merge " " ${depends[@]}`
    _provides=`merge " " ${provides[@]}`
    _conflicts=`merge " " ${conflicts[@]}`
    sed -i "s:PKGNAME:${pkgname}:g" PKGBUILD
    sed -i "s:VERSION:${pkgver}:g" PKGBUILD
    sed -i "s:DEPENDENCY:${_depends}:g" PKGBUILD
    sed -i "s:PROVIDES:${_provides}:g" PKGBUILD
    sed -i "s:CONFLICTS:${_conflicts}:g" PKGBUILD
    sed -i "s:PKGNAME:${pkgname}:g" _service
    osc add `ls`
    osc commit -m init
done