#!/bin/bash
#
# Script de configuracion de la plantilla de las diferentes distros WSL
# Requiere common.inc en /mnt/s/bin

cp /mnt/c/Windows/Temp/wsl_tools.tar.gz /tmp
cd /tmp
tar -xzf wsl_tools.tar.gz 2> /dev/null > /dev/null
export PATH=/tmp/wsl_tools:$PATH
wsl_make_base.sh