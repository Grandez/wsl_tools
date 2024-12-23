#!/bin/bash
#
# Script de post instalacion de una nueva distro de WSL
# Requiere common.inc en /mnt/s/bin

trap "exit 1" TERM
export PIDP=$$

source /mnt/s/bin/common.inc

test `id -u` -gt 0 && noroot
test -f /etc/${WSL_DISTRO_NAME].conf && already_run $0


change_hosts() {
    grep -q $WSL_DISTRO_NAME /etc/hosts
    test $? -eq 0 && return
    
    grep -v WSLHOST /etc/hosts > /tmp/hosts
    echo "127.0.0.1       $WSL_DISTRO_NAME # WSLHOST" > /etc/hosts
    cat /tmp/hosts >> /etc/hosts
    rm /tmp/hosts
}

change_fs() {
    base=`ls -l /mnt/s`
    LN=`echo ${base##*->} | sed s/shared/$WSL_DISTRO_NAME/`
    rm -i /mnt/m
    ln -s $LN /mnt/m
}

change_wsl() {
        sed -i "s/hostname[ \t]*=[ \t]*[a-zA-Z0-9\-_]*/hostname = $WSL_DISTRO_NAME/" /etc/wsl.conf
}

change_hosts
change_fs
change_wsl

touch /etc/${WSL_DISTRO_NAME}

info Post instalacion realizada