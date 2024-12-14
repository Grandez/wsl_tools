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

info2 Instalando Nginx

create_log_file $0

apt install -y nginx >> $LOG 2>> $LOG

grep -q nginx /etc/profile.d/zzz_wsl.sh
[ $? -ne 0 ] && echo "" >> /etc/profile.d/zzz_wsl.sh 2>> $LOG && echo service nginx start 2>> $LOG

cp /mnt/s/wsl_tools/dat/nginx_${WSL_DISTRO_NAME}.conf /mnt/m/conf > /dev/null 2> /dev/null
if [ $? -ne 0 ] ; then 
    warn No existe una definicion del servidor NGINX para la distro ${WSL_DISTRO_NAME}
    warn Creando definicion vacia
    touch /mnt/m/conf/nginx_${WSL_DISTRO_NAME}.conf
fi

ln -s /etc/nginx/sites-available/${WSL_DISTRO_NAME}  /mnt/m/conf/nginx_${WSL_DISTRO_NAME}.conf
rm  -f /etc/nginx/sites-enabled/default > /dev/null 2> /dev/null
ln -s /etc/nginx/sites-enabled/${WSL_DISTRO_NAME}  /etc/nginx/sites-available/${WSL_DISTRO_NAME}

