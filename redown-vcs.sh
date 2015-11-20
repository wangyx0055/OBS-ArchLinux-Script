#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir/../
ARCH=Arch_Extra
SLEEP="10"
if [ `ps -e | grep -c $(basename $0)` -gt 2 ]; then exit 0; fi

ls -d */|grep -v _SCRIPT|sed 's:/::g'|while read line
do
  case $line in 
  "home:mazdlc:missing"|"home:mazdlc:multilib")
    basedir=$_basedir/../$line
    REPO="$line"
    cd $basedir
    URL="https://build.opensuse.org/project/monitor/${REPO}?arch_x86_64=1&defaults=0&broken=1&blocked=1&scheduled=1&repo_${ARCH}=1"
    nstatus=`curl -s $URL|grep -oP "(?<=${REPO}/)[a-z0-9-]+"|uniq`
    [[ z$nstatus == z ]] && continue
    echo $nstatus | while read line
    do
        sleep $SLEEP
        cd $basedir/$line
        echo Package $line
        osc service remoterun $REPO $line
    done
  ;;
  *)
    basedir=$_basedir/../$line
    REPO="$line"
    cd $basedir
    URL="https://build.opensuse.org/project/monitor/${REPO}?arch_x86_64=1&defaults=0&broken=1&blocked=1&scheduled=1&repo_${ARCH}=1"
    nstatus=`curl -s $URL|grep -oP "(?<=${REPO}/)[a-z0-9-]+"|uniq`
    [[ z$nstatus == z ]] && continue
    for vcs in git svn hg bzr
    do
      echo $nstatus | grep -P "\-${vcs}$" | while read line
      do
        sleep $SLEEP
        cd $basedir/$line
        echo Package $line
        osc service remoterun $REPO $line
      done
    done
  ;;
  esac
done
