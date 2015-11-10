#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir/../
ARCH=Arch_Extra

ls -d */|grep -v _SCRIPT|sed 's:/::g'|while read line
do
  case $line in 
  "home:mazdlc:missing"|"home:mazdlc:multilib")
    basedir=$_basedir/../$line
    REPO="$line"
    cd $basedir
    nstatus=`curl -s "https://build.opensuse.org/project/monitor/${REPO}?arch_x86_64=1&defaults=0&repo_${ARCH}=1"|grep -oP "(?<=status'>)broken|blocked|scheduled"|head -1`  #|blocked|scheduled
    [[ z$nstatus == z ]] && continue
    ls | while read line
    do
        cd $basedir/$line
        echo Package $line
        [[ z`osc results|grep broken` == z ]] || osc service remoterun $REPO $line
        [[ z`osc results|grep scheduled` == z ]] || osc service remoterun $REPO $line
        [[ z`osc results|grep blocked` == z ]] || osc service remoterun $REPO $line
    done
  ;;
  *)
    basedir=$_basedir/../$line
    REPO="$line"
    cd $basedir
    nstatus=`curl -s "https://build.opensuse.org/project/monitor/${REPO}?arch_x86_64=1&defaults=0&repo_${ARCH}=1"|grep -oP "(?<=status'>)broken|blocked|scheduled"|head -1`
    [[ z$nstatus == z ]] && continue
    for vcs in git svn hg bzr
    do
      ls | grep -P "\-${vcs}$" | while read line
      do
        cd $basedir/$line
        echo Package $line
        [[ z`osc results|grep broken` == z ]] || osc service remoterun $REPO $line
        [[ z`osc results|grep scheduled` == z ]] || osc service remoterun $REPO $line
        [[ z`osc results|grep blocked` == z ]] || osc service remoterun $REPO $line
      done
    done
  ;;
  esac
done