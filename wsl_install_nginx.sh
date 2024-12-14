#!/bin/bash
#######################################################################
# Instalador de Nginx
#
#######################################################################
preload_err() {
  RED='\033[0;31m'
  NC='\033[0m' 
  echo -e "${RED}FALTA EL SCRIPT $* ${NC}"        
}

# Prepara cosas
source /mnt/s/wsl_tools/wsl_common.sh
if [ $? -ne 0 ] ; then preload_err wsl_common.sh && exit 127 ; fi
    
source /mnt/s/wsl_tools/wsl_env.sh
if [ $? -ne 0 ] ; then preload_err wsl_common.sh && exit 127 ; fi

info2 Instalando Nginx

create_log_file $0

apt install -y nginx
