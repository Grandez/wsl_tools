#!/bin/bash
###########################################################
# Script de instalacion de paquetes basicos
# Requiere common.inc en el mismo directorio
#
###########################################################

BASE=${0%%/*}

source ${BASE}/common.inc
source ${BASE}/wsl_base_dialog.inc

test `id -u` -gt 0 && noroot

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

apt update
apt-get install -y net-tools \
                   gedit \ 
                   neofetch  &>> $LOG

apt install -y r-base  &>> $LOG

                  