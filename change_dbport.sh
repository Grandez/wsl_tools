#!/bin/sh
##################################################
# Cambia los puertos expuestos en Docker
# REQUIERE ROOT
##################################################

SRC=1555
TGT=4521

if [ $UID != 0 ] ; then
    echo Este script se debe ejecutar como root
    exit 1
fi
    
OLD=`pwd`
cd /var/lib/docker/containers
for i in `find . -name "hostconfig.json"` ; do echo sed -i 's/${SRC}/${TGT}/g' $i ; done
for i in `find . -name "config.v2.json"`  ; do echo sed -i 's/${SRC}/${TGT}/g' $i ; done
cd $OLD
