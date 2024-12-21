#!/bin/bash
#######################################################################
# Instalador de Docker y docker compose
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
                       docker-buildx-plugin \
                       docker-compose-plugin >> $LOG 2>> $LOG
                       
info2 Configurando Docker

mkdir /mnt/m/docker
mkdir /mnt/m/docker/data

cp -f /mnt/s/wsl_tools/dat/docker.json /etc/docker/daemon.json
chown root:docker /etc/docker/daemon.json
