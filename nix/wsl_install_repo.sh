#!/bin/bash  
# SOCIO! SI ME LEES, EN LA URL TIENES LA DOC PARA UN REGISTRY PRIVADO
# SOCIO! SI ME LEES, DIMELO
#
#######################################################################
# Instalador de repositorios pivados maven y docker
#aQUI SE GUARDARAN LAS COSAS NUESTRAS
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

check_prerequisites() {
  # Aqui miramos si la wsl tiene lo que necesito
  # Tiraremos de una maquina docker
}
info2 Instalando Repositorio

create_log_file $0

apt install nginx apache2-utils -y
nano /etc/nginx/conf.d/registry.conf

#de: 
# https://earthly.dev/blog/private-docker-registry/
# esto es registry.cnf (ira en dat)

# La configuracion
#
# server {
#     listen 80;
#     server_name private.linuxbuz.com;
#     access_log /var/log/nginx/access.log;
#     error_log /var/log/nginx/error.log;
#

# location / {                                                                 
#     if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {install -m 0755 -d /etc/apt/keyrings >> $LOG 2>> $LOG
#     return 404;                                                             
#     }                                                                       curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc >> $LOG 2>> $LOG
#                                                                             chmod a+r /etc/apt/keyrings/docker.asc                                                  >> $LOG 2>> $LOG
#     proxy_pass http://localhost:5000;                                       
#     proxy_set_header Host $http_host; # required for docker client's sake   # Add the repository to Apt sources:
#     proxy_set_header X-Real-IP $remote_addr; # pass on real client's IP     echo \
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#     proxy_set_header X-Forwarded-Proto $scheme;                               $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#     proxy_read_timeout 900;                                                   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#     }                                                                         
# }                                                                           apt-get update >> $LOG 2>> $LOG

# Ejemplo

# server {                                                                    
#     listen 80;                                                              apt-get -qq install -y docker-ce \
#     server_name private.linuxbuz.com;                                                              docker-ce-cli \
#     access_log /var/log/nginx/access.log;                                                          containerd.io \
#     error_log /var/log/nginx/error.log;                                                            docker-buildx-plugin \
#                                                                                                    docker-compose-plugin >> $LOG 2>> $LOG
# location / {                                                                                       
#     if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {info2 Configurando Docker
#     return 404;                                                             
#     }                                                                       mkdir /mnt/s/docker
#                                                                             cp -f /mnt/s/wsl_tools/dat/docker.json /etc/docker/daemon.json
#     proxy_pass http://localhost:5000;                                       chown root:docker /etc/docker/daemon.json
#     proxy_set_header Host $http_host; # required for docker client's sake   sed -i "s/docker_wsl_data/\/mnt\/m\/docker/g" /etc/docker/daemon.json
#     proxy_set_header X-Real-IP $remote_addr; # pass on real client's IP     
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;            
#     proxy_set_header X-Forwarded-Proto $scheme;                             
#     proxy_read_timeout 900;                                                 
#     }                                                                       
# }                                                                           