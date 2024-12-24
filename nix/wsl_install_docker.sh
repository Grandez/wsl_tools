#!/bin/bash
#######################################################################
# Instalador de Docker y docker compose
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

SHRNIX=/mnt/s/wsl_tools/nix

# Prepara cosas
source ${SHRNIX}/wsl_common.sh
if [ $? -ne 0 ] ; then preload_err wsl_common.sh && exit 127 ; fi
    
source ${SHRNIX}/wsl_env.sh
if [ $? -ne 0 ] ; then preload_err wsl_common.sh && exit 127 ; fi

test `id -u` -gt 0 && noroot

info2 Instalando Docker

create_log_file $0

install -m 0755 -d /etc/apt/keyrings >> $LOG 2>> $LOG

curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc >> $LOG 2>> $LOG
chmod a+r /etc/apt/keyrings/docker.asc                                                  >> $LOG 2>> $LOG

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
apt-get update >> $LOG 2>> $LOG

apt-get -qq install -y docker-ce \
                       docker-ce-cli \
                       containerd.io \
                       docker-compose-plugin >> $LOG 2>> $LOG
                       
info2 Configurando Docker

mkdir /mnt/m/docker        >> $LOG 2>> $LOG
mkdir /mnt/m/docker/data   >> $LOG 2>> $LOG

# Parar Docker

info Deteniendo servicio

echo deteniendo servicio
while : ; do
    systemctl is-active --quiet docker
    [[ $? -ne 0 ]] && break
    systemctl stop docker
    sleep 2 # Para los triggers
done


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
