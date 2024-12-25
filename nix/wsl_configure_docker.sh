#!/bin/bash
#######################################################################
# Configura Docker a partir de una base que se ejecuta en systemctl
#
# Este software se distribuye de acuerdo con la licencia/EULA MIT
# Ver LICENSE para mas informacion (en ingles)
#
#######################################################################
preload_err() {
  RED='\033[0;31m'
  NC='\033[0m' 
  echo -e "${RED}FALTA EL SCRIPT $* ${NC}"        
}

trap "exit 1" TERM
export PIDP=$$

TOOLS=/mnt/s/wsl_tools
NIX=${TOOLS}/nix
DAT=${TOOLS}/dat

# Prepara cosas
source ${NIX}/wsl_common.sh
if [ $? -ne 0 ] ; then preload_err wsl_common.sh && exit 127 ; fi
    
source ${NIX}/wsl_env.sh
if [ $? -ne 0 ] ; then preload_err wsl_common.sh && exit 127 ; fi

test `id -u` -gt 0 && noroot

SRV=/usr/lib/systemd/system
LNK=/mnt/m/conf/docker

dat_2_cnf() {
   for f in "$@" ; do
     cp -f ${DAT}/$f ${CNF}    
   done
}
# Esta es la funcion que asigna sockets, puertos, etc.
# Estas funciones SI cambian el sistema

make_link() {
   [[ ! -f ${SRV}/$1.old ]] &&  cp ${SRV}/$1  ${SRV}/$1.old
   ln -s ${SRV}/$1 ${LNK}/$1
}

custom_environment() {
   chmod u+s /usr/bin/dock*
    
   sed -i "s/\/run\/docker\.sock/\/run\/${WSL_DISTRO_NAME}_docker.sock/g" /mnt/m/conf/docker/docker.json
   sed -i "s/\/run\/docker\.sock/\/run\/${WSL_DISTRO_NAME}_docker.sock/g" /mnt/m/conf/docker/daemon.json
   sed -i "s/\/run\/docker\.sock/\/run\/${WSL_DISTRO_NAME}_docker.sock/g" /mnt/m/conf/docker/docker.socket
    
   [[ ! -f ${SRV}/docker.service.old ]] &&  cp ${SRV}/docker.service  ${SRV}/docker.service.old
   [[ ! -f ${SRV}/docker.socket.old  ]] &&  cp ${SRV}/docker.socket   ${SRV}/docker.socket.old
  
   ln -s ${SRV}/docker.service ${LNK}/docker.service > /dev/null 2> /dev/null
   ln -s ${SRV}/docker.socket  ${LNK}/docker.socket  > /dev/null 2> /dev/null
}
custom_docker() {
    [[ -f /var/lib/docker/containers.old ]]  && return
    mv /var/lib/docker/containers /var/lib/docker/containers.old
    mv /var/lib/docker/volumes    /var/lib/docker/volumes.old
    ln -s /mnt/s/docker/data/containers /var/lib/docker/containers
    ln -s /mnt/s/docker/data/volumes    /var/lib/docker/volumes
}
custom_user() {
    tok=`grep default /etc/wsl.conf`
    USER=`echo ${tok##*=} | xargs`
    
    if [[ -f .bash_aliases ]] ; then
        grep -q docker .bash_aliases
        [[ $? -gt 0 ]] && cat $DAT/alias_docker.sh >> /home/$USER/.bash_aliases
    else
        cp $DAT/alias_docker.sh  /home/$USER/.bash_aliases
    fi
    chown $USER:$USER  /home/$USER/.bash_aliases
    
    cp -f /mnt/m/dat/local/docker/* /usr/bin/local
    chmod 777 /usr/bin/local *
}
prepare_environment() {
  info creando entorno  
  mkdir /mnt/m/conf          > /dev/null 2> /dev/null
  mkdir /mnt/m/conf/docker   > /dev/null 2> /dev/null
  mkdir /mnt/m/docker        > /dev/null 2> /dev/null
  mkdir /mnt/m/docker/data   > /dev/null 2> /dev/null

  export CNF=/mnt/m/conf/docker  
  
  dat_2_cnf docker.json daemon.json docker.service docker.socket
  
}


stop_service docker
prepare_environment
custom_environment
custom_docker
custom_user

systemctl --system daemon-reload
warn Salga del sistema
warn Reinicie WSL   
   
exit 4




# Parar Docker


info configurando


# Configuracion a daemon.json
# Cambiamos el socket

echo copiando ficheros
cp -f /mnt/s/wsl_tools/dat/docker.json     /etc/docker/daemon.json
cp -f /mnt/s/wsl_tools/dat/docker.sh       /etc/profile.d/docker.sh
cp -f /mnt/s/wsl_tools/dat/docker.service  /usr/lib/systemd/docker.service

chown root:root /etc/docker/daemon.json
chown root:root /etc/profile.d/docker.sh
chown root:root /usr/lib/systemd/docker.service
chmod 775 /etc/profile.d/docker.sh
chmod 644 /usr/lib/systemd/docker.service

echo configurando
sed -i "s/var\/run\/docker\.sock/var\/run\/${WSL_DISTRO_NAME}_docker\.sock/g" /etc/docker/daemon.json
sed -i "s/var\/run\/docker\.sock/var\/run\/${WSL_DISTRO_NAME}_docker\.sock/g" /etc/profile.d/docker.sh

chmod u+s /usr/bin/dock*
