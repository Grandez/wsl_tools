#!/bin/sh
##################################################
# Cambia la version del proyecto
# change_version old new
#
##################################################

# if [ $# != 2 ] ; then
#     echo Faltan las versiones
#     exit 1
# fi

for i in `find . -name "pom.xml"` ; do sed -i "s/v3\.0\.6/v4\.0\.0/g" $i ; done

