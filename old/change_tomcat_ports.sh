#!/bin/sh
##################################################
# Cambia los puertos de tomcat
#
##################################################

SRC=">80"
TGT=">40"

change_ports () {
  echo Parametros -$1- -$2- -$3-
  for i in `find . -name "*.$1"` ; do 
     grep -qF "$2" $i
     if [ $? -eq 0 ] ; then
         echo sed -i "s/$2/$3/g" $i
     fi
  done      
}
  
if [ $# == 0 ] ; then
    echo Falta el directorio del proyecto
    exit 1
fi
    
OLD=`pwd`
cd $1
change_ports xml ">80" ">40"
change_ports xml ">90" ">50"
change_ports properties "=80" "=40"
change_ports properties "=90" "=50"
change_ports properties ":80" ":40"
change_ports properties ":90" ":50"

cd $OLD
