# Mensajes y herramietns comunes

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' 

INFO=$GREEN
WARN=$BLUE
ERR=$RED

2stderr() { echo -e $@ 1>&2;  }

noroot () { 
   2stderr ${ERR} Este script se debe ejecutar como root ${NC} 
   kill -s TERM $PIDP
}
 already_run () {
   2stderr ${ERR} El script $1 parece que ya se ha ejecutado ${NC} 
   kill -s TERM $PIDP
}

info() {
   echo -e ${INFO}`date +%T` - $@${NC} | tee -a $LOG
}

info2() {
   echo -e ${WARN}`date +%T` - $@${NC} | tee -a $LOG
}

err() {
   2stderr ${ERR} $* ${NC} 
   kill -s TERM $PIDP
}

create_log_file () {
   CMD=${1##*/}
   NAME=${CMD%%.*} 
   export LOG=/mnt/s/logs/${WSL_DISTRO_NAME}_${NAME}.log
   touch $LOG
}
