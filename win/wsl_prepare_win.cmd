:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para inicializar el entorno en windows
:: Este script se deberia copiar de la web
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

REM VARIABLES A CONFIGURAR 

REM Variables de configuracion para WSL
REM ATENCION A LA DIFERENCIA ENTRE WSL_MACHINES_WIN Y WSL_MACHINES_WSL

SET MACHINES_DRIVE=T:
SET MACHINES_WIN=C:\Maquinas
SET MACHINES_WSL=C:/Maquinas
SET USER=kvothe
SET PWD=kvothe
SET GROUP=temerant

SET CWD=%CD%

CALL :COMMON

CALL :CHECK_SYSTEM  && IF %RC% NEQ 0 GOTO :END
CALL :CHECK_DRIVE   && IF %RC% NEQ 0 GOTO :END
CALL :CREATE_SHARED && IF %RC% NEQ 0 GOTO :END
CALL :CREATE_CONFIG && IF %RC% NEQ 0 GOTO :END

CALL :INFO Preparacion inicial del entorno Windows realizada
CALL :INFO Siguiente paso: %MACHINES_DRIVE%\Shared\wsl_tools\wsl_create_base
CD %CWD% > \\.\NUL 2> \\.\NUL

EXIT /B %RC%


:: Chequea los programas necesarios
:: WSL, git, etc
:CHECK_SYSTEM
  CALL :PROGRESS Verificando sistema
  
  wsl -l > \\.\NUL 2> \\.\NUL
  IF %ERRORLEVEL% NEQ 0 (
     CALL :ERR WSL no esta activado
     SET RC=32
     GOTO :END
  )   

  git --version > \\.\NUL 2> \\.\NUL
  IF %ERRORLEVEL% NEQ 0 (
     CALL :ERR Es necesario tener accesible el programa %BOLD%git%NC% 
     SET RC=32                     
     GOTO :END                     
  )   
  
  GOTO :EOF  
  
:: Verifica o crea el disco virtual para las distros 
:CHECK_DRIVE
   CALL :PROGRESS Verificando o creando discos
   IF NOT EXIST %MACHINES_WIN% MKDIR %MACHINES_WIN%
   IF NOT EXIST %MACHINES_WIN% (
      CALL :ERR No se ha podido crear el directorio %MACHINES_WIN%
      SET RC=32                     
   )
   
   VOL %MACHINES_DRIVE% > \\.\NUL 2> \\.\NUL
   IF %ERRORLEVEL% NEQ 0 (
      CALL :INFO No existe el disco virtual %MACHINES_DRIVE%
      CALL :INFO Creando disco virtual con %BOLD%SUBST%NC%
      SUBST %MACHINES_DRIVE% %MACHINES_WIN%
      VOL %MACHINES_DRIVE% 
      IF %ERRORLEVEL% NEQ 0 (
         CALL :ERR No se ha podido crear el disco virtual %MACHINES_DRIVE%
         SET RC=32
      )
   )   

   :: Variable de entorno para el disco virtual
   SETX /s %COMPUTERNAME% /U %USERNAME% WSL_MACHINES_DRIVE %MACHINES_DRIVE% > \\.\NUL 2> \\.\NUL
   
   GOTO :EOF     
   
:: Crea el directorio shared y su contenido
:CREATE_SHARED
   CALL :PROGRESS Verificando o creando entorno compartido
   IF NOT EXIST %MACHINES_DRIVE%\shared MKDIR %MACHINES_DRIVE%\shared
   IF NOT EXIST %MACHINES_DRIVE%\shared (
      CALL :ERR No se ha podido crear el directorio shared en %MACHINES_DRIVE%
      GOTO :EOF
   )
   %MACHINES_DRIVE%
   CD %MACHINES_DRIVE%\shared
   MD logs > \\.\NUL 2> \\.\NUL

   CALL :PROGRESS Recuperando scripts

   :: Obtenemos los scripts
   SET METHOD=pull
   CD wsl_tools
   IF %ERRORLEVEL% NEQ 0 (
      SET METHOD=clone
      CD ..
   )   

   git %METHOD% https://github.com/Grandez/wsl_tools.git > \\.\NUL 2> \\.\NUL
   IF %ERRORLEVEL% NEQ 0 (
      CALL :ERR No se han podido recuperar los scripts
      GOTO :EOF
   )
   GOTO :EOF

:: Guardamos la configuracion actual en wsl_env.cmd
:: Se sobreescribe si existiera
:CREATE_CONFIG
   SET ENV=%MACHINES_DRIVE%\shared\wsl_tools\win\wsl_env.cmd
   ECHO. > %ENV%
   ECHO SET "WSL_MACHINES_DRIVE=%MACHINES_DRIVE%" >> %ENV%
   ECHO SET "WSL_MACHINES_WIN=%MACHINES_WIN%"     >> %ENV%
   ECHO SET "WSL_MACHINES_WSL=%MACHINES_WSL%"     >> %ENV%
   ECHO SET "WSL_USER=%USER%"                     >> %ENV%
   ECHO SET "WSL_PWD=%PWD%"                       >> %ENV%
   ECHO SET "WSL_GROUP=%GROUP%"                   >> %ENV%
   GOTO :EOF
   
:COMMON
  SET RC=0
  SET NC=[0m 
  SET BOLD=[1m
  SET GREEN=[32m
  SET BLUE=[1;34m
  SET RED=[31m
  
  SET INFO=%GREEN%
  SET WARN=%BLUE%
  SET ERR=%RED%
  
  
  SET T=%TIME:~0,8%
  GOTO :EOF
   
:PROGRESS
  echo %GREEN%%T% - %* %NC%
  GOTO :EOF
:INFO
  echo %WARN%%T% - %* %NC%
  GOTO :EOF
:ERR
  SET RC=16
  ECHO %RED%%T% - %* %NC% 1>&2
  GOTO :EOF
:HELP
   ECHO Crea la distro base
   ECHO %0 wsl_create_base [--name nombre] [--from distro_name]
   ECHO    --name nombre: Nombre de la maquina base. Por defecto: %BOLD%base%NC%
   ECHO    --from distro_name: Origen de la distro del Store. Por defecto: %BOLD%Ubuntu-24.04%NC%
   ECHO    %BOLD%Nota: Se asume que el disco virtual de maquinas es M: %NC%
   GOTO END
   
:END 
   CD %CD%
   EXIT /B %RC%
