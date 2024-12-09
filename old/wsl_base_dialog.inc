#!/bin/bash

HEADER='Configuracion de distro'
INPUT=
USER=juan

start() {
  LBL=( \
      "Bienvenido__" \
      "Ahora necesitamos especificar cierta informacion para acabar de configurar esta distro" \
      "para utilizar como plantilla para el resto de distros__" \
      "X - Usuario y password corporativo: " \
      "Este sera el usuario compartido por cada distro_" \
      "X - Grupo corporativo: " \
      "Grupo al que pertenecera el usuario corporativo_" \
      "X - Ubicacion distros en Windows: " \
      "Este es el directorio Windows donde se guarda la informacion de las distros_" \
      
  )
  MSG=`echo ${LBL[@]} | sed 's/_/   \n/g'`
  dialog --begin 10 60 --backtitle "$HEADER" --title "Info" --msgbox "$MSG" 20 80
}
input_data () {
  while : ; do
    var=$(dialog --backtitle "$HEADER" \
                    --title "$1" \
                    --inputbox "$2" $3 $4 $5 \
                    --stdout)

    [[ -n $var ]] && break
  done
  INPUT=$var
}
input_pwd () {
  while : ; do
    var=$(dialog --backtitle "$HEADER" \
                    --title "$1" \
                    --passwordbox "$2" $3 $4 \
                    --stdout)

    [[ -n $var ]] && break
  done
  INPUT=$var
}

obtener_usuario() {
  USER=`id -nu 2000 2> /dev/null`
  if [ $? -eq 0 ] ; then
     export USER=$USER
     txt="Se ha encontrado el usuario $USER"
     dialog --title "Usuario existente" --msgbox "$txt" 10 50
     return 0
  fi
  
  input_data "Usuario corporativo" "Usuario (UID 2000)" 10 30 $USER
  export USER=$INPUT

  PWD1=pwd1
  PWD2=pwd2
  T=Password
  while [ "$PWD1" != "$PWD2" ] ; do 
     input_pwd "$T" "Usuario ($USER)" 10 30 
     PWD1=$INPUT
     input_pwd "Verifique password" "Usuario ($USER)" 10 30 
     PWD2=$INPUT
     T="Passwords no coinciden"
  done
  export PWD=$PWD1
  return 1
}

obtener_grupo() {
  GROUP=`getent group | grep -q 3000 2> /dev/null`
  if [ $? -eq 0 ] ; then
    export GROUP=`echo $GROUP | cut -f1 -d':'` 
     txt="Se ha encontrado el grupo " $GROUP
     dialog --title "Grupo existente" --msgbox "$txt" 10 50
     return 0
  fi
  
  input_data "Grupo corporativo" "Grupo (GID 3000)" 10 30 GROUP
  GROUP=$INPUT
  return 1
}

obtener_basedir() {
   if [ -f "/mnt/m" ] ; then
      if [ -f "/mnt/s" ] ; then
         txt="Se han encontrado los sistemas de archivos"
         dialog --title "Sistemas de archivos" --msgbox "$txt" 10 50
         return 0
      fi  
   fi
   
  ROOT="Windows/Temp"
  RC=1
  T=Sistemas de archivos
  while [ $RC -gt 0 ] ; do 
     input_data "$T" 'Introduzca la ruta absoluta del directorio/disco raiz de ubicacion de las distros en Windows desde C:\' 10 50 $ROOT
     [ -d "/mnt/c/${INPUT}" ] && RC=0
     T=`echo $INPUT no existe`
  done
  export ROOT=$INPUT
  return 1
}

check_config() {
   T="\nUsuario      :  $USER"
   T="$T\nPassword     :  *****"
   T="$T\nGrupo        :  $GROUP"
   T="$T\nUbicacion    :  $ROOT"
   dialog --title "Confirme la informacion" --yesno "$T" 10 50
   return $?
}

get_config() {
   start
   RC=1
   while [ $RC -gt 0 ] ; do
      obtener_usuario
      export SET_USER=$?
      obtener_grupo
      SET_GROUP=$?
      obtener_basedir
      SET_DIR=$?
      check_config
      RC=$?
   done
}

