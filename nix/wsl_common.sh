#######################################################################
# Funciones, variables y entorno comun para todos los scripts
# 
# Se carga con source 
# Se puede tambien con . name
#
# This software is licensed under the MIT License.
# See the LICENSE file for more details.
#
###########################################################

# Mensajes y herramietns comunes

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BLACK='\033[0;30m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

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
warn() {
   echo -e ${WARN}`date +%T` - $@${NC} | tee -a $LOG
}

err() {
   2stderr ${ERR} $* ${NC} 
   kill -s TERM $PIDP
}
warn() {
   echo -e ${WARN}`date +%T` - $@${NC} | tee -a $LOG    
}
create_log_file () {
   CMD=${1##*/}
   NAME=${CMD%%.*} 
   export LOG=/mnt/s/logs/${WSL_DISTRO_NAME}_${NAME}.log
   touch $LOG
}


stop_service() {
   info Deteniendo $1

   while : ; do
       systemctl is-active --quiet $1
       [[ $? -ne 0 ]] && break
       systemctl stop $1
       sleep 2 # Para los triggers
   done
   sleep 2 # Este va de propina
    
}
