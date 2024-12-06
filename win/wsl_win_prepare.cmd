:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para inicializar el entorno en windows
:: LAS FUNCIONES "VAN AL FINAL"
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

SET PWD=%CD%

ECHO Verificando sistema

:: Chequear programas

wsl -l > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   ECHO FALTA WSL
   exit /b 32
)   

: Chequear que es WSL 2

git --version > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   ECHO FALTA GIT
   exit /b 32
)   

ECHO Preparando entorno

:: SOLO SE GESTIONAN DISCOS NO DIRECTORIOS

SET ROOT=%1
IF "%ROOT%" == "" SET ROOT=M

VOL %ROOT%: > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   ECHO NO EXISTE EL DISCO VIRTUAL %ROOT%
   EXIT /B 32
)   

:: Creamos el directorio Shared
MKDIR %ROOT%:\Shared > \\.\NUL 2> \\.\NUL
%ROOT%:
CD %ROOT%:\Shared
IF %ERRORLEVEL% NEQ 0 (
   ECHO NO SE HA PODIDO CREAR EL DIRECTORIO Shared en %ROOT%
   CD %PWD%
   EXIT /B 32
)   
:: Variable de entorno
SETX /s %COMPUTERNAME% /U %USERNAME% WSL_ROOT %ROOT%: > \\.\NUL 2> \\.\NUL

ECHO Recuperando scripts

:: Obtenemos los scripts
SET METHOD=pull
CD wsl_tools
IF %ERRORLEVEL% NEQ 0 SET METHOD=clone

git %METHOD% https://github.com/Grandez/wsl_tools.git > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   ECHO NO SE HAN PODIDO OBTENER LOS SCRIPTS 
   CD %PWD%      
   EXIT /B 32
)   

ECHO Preparacion inicial del entorno Windows realizada
ECHO Siguiente paso: %ROOT%:\Shared\wsl_tools\wsl_create_base
CD %PWD% > \\.\NUL 2> \\.\NUL
