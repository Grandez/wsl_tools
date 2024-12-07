# Mensajes y herramietns comunes

RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' 

2stderr() { echo -e $@ 1>&2;  }

noroot () { 
   2stderr ${RED} Este script se debe ejecutar como root ${NC} 
   kill -s TERM $PIDP
}
 already_run () {
   2stderr ${RED} El script $1 parece que ya se ha ejecutado ${NC} 
   kill -s TERM $PIDP
 
}

info() {
   echo -e ${BOLD}`date +%T` - $@${NC} | tee -a $LOG
}

log_file () {
   ROOT=${0%%/*}
   NAME=${0##*/}
   NAME=${NAME%%.*}
   export LOG=/tmp/${NAME}.log
}