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
     txt="Se ha encontrado el usuario $USER"
     dialog --title "Usuario existente" --msgbox "$txt" 10 50
     return 1
  fi
  
  input_data "Usuario corporativo" "Usuario (UID 2000)" 10 30 $USER
  USER=$INPUT

  PWD1=pwd1
  PWD2=pwd2
  T=Password
  while [ "$PWD1" != "$PWD2" ] ; do 
     input_pwd "$T" "Usuario ($USER)" 10 30 
     PWD1=$INPUT
     echo password ers $PWD1
     input_pwd "Verifique password" "Usuario ($USER)" 10 30 
     PWD2=$INPUT
     T="Passwords no coinciden"
  done
  PWD=$PWD1

}

obtener_basedir() {
dialog --begin 10 30 \
       --backtitle "$HEADER" \
       --title "Info" \
       --msgbox 'Ahora necesitamos cierta informacion basica para configurar la distro' 10 30 \
       --inputbox 'Etiqueta' 20 30

#  input_data "Usuario corporativo" "Usuario (UID 2000)" 10 30 $USER
#  USER=$INPUT

}

###########################################################

#dialog --begin 10 30 \
#       --backtitle "$HEADER" \
#       --title "Info" \
#       --msgbox 'Ahora necesitamos cierta informacion basica para configurar la distro' 10 30 \
#       --and-widget --begin 20 30 \
#       --inputbox 'Etiqueta' 

start
obtener_usuario
# obtener_basedir








