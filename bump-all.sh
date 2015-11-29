#!/bin/sh
ESHELL=zsh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir/../

if [ `ps -e | grep -c $(basename $0)` -gt 2 ]; then exit 0; fi

ls -d */|grep -v _SCRIPT|sed 's:/::g'|while read line
do
  echo $line
  case $line in 
  "home:mazdlc:missing"|"home:mazdlc:multilib")
    #continue
    basedir=$_basedir/../$line
    REPO="$line"
    SRC_REPO=community
    PKGBUILD_PREFIX="https://projects.archlinux.org/svntogit/${SRC_REPO}.git/plain/trunk/PKGBUILD?h=packages/"
    cd $basedir
    ls|while read line
    do
      cd $basedir/$line
      pkgname=""
      pkgver=""
      pkgrel=""
      depends=""
      echo "${PKGBUILD_PREFIX}${line}"
      eval "`curl -s "${PKGBUILD_PREFIX}${line}"|grep -vP '^options='`"
      if [[ $pkgver != "" ]] ; then
        curver=`cat PKGBUILD | grep -oP '(?<=pkgver=)\S+$'`
        currel=`cat PKGBUILD | grep -oP '(?<=pkgrel=)\S+$'`
        if [[ ${pkgver}${pkgrel} != ${curver}${currel} ]] ; then
            osc up
            sed -i "s:^pkgrel=\S*:pkgrel=${pkgrel}:g" PKGBUILD
            sed -i "s:^pkgver=\S*:pkgver=${pkgver}:g" PKGBUILD
            echo "Bump $line from ${curver}-${currel} to $pkgver-$pkgrel"
            osc commit -m bump
        else
            echo "SKIP"
        fi
      else
        echo "$line Not found on Archlinux repo"
      fi
    done
    
    cd $basedir
    ls */bump.sh | while read line
    do
      $ESHELL $line
    done
  ;;
  *)
    # do not try to bump when packages are blocked or scheduled
    ARCH=Arch_Extra
    CHKURL="https://build.opensuse.org/project/monitor/${line}?arch_x86_64=1&defaults=0&blocked=1&scheduled=1&repo_${ARCH}=1"
    nstatus=`curl -s $CHKURL|grep -oP "(?<=${line}/)[a-z0-9-]+"|uniq`
    [[ z$nstatus == z ]] || continue
    
    basedir=$_basedir/../$line
    REPO="$line"
    cd $basedir
    echo $basedir
    ls */bump.sh | while read line
    do
      $ESHELL $line
    done
    
    for vcs in git svn hg bzr
    do
      ls | grep -P "\-${vcs}$" | while read line
      do
        function rand(){
          min=$1
          max=$(($2-$min+1))
          num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
          echo $(($num%$max+$min))
        }
        
        function bump(){
          #osc api -m POST "source/$REPO/$1?cmd=runservice"
          osc service remoterun $REPO $1
          osc rebuildpac $REPO/$1
        }
        
        
        case $line in
        libutvideo-git)
          true
        ;;
        fceux-svn|xnp2-git)  #these packages are rarely updated
          NUM=$(rand 111 999)
          echo $NUM
          [[ $NUM == "116" ]] && bump $line
        ;;
        mitsuba-hg|ardour-git) 
        #these packages takes too long to build
          NUM=$(rand 111 300)
          echo $NUM
          [[ $NUM == "116" ]] && bump $line
        ;;
        wireshark-git|mkvtoolnix-git|edb-debugger-git|gimp-painter-git|amule-dlp-git|qsanguoshav2-git) 
        #these packages takes long to build
          NUM=$(rand 111 200)
          echo $NUM
          [[ $NUM == "116" ]] && bump $line
        ;;
        *) #other packages are updated frequently
          NUM=$(rand 111 155)
          echo $NUM
          [[ $NUM == "116" ]] && bump $line
        ;;
        esac
      done
    done
    
  ;;
  esac
  
done