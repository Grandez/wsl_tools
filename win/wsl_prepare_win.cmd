:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para inicializar el entorno en windows
:: LAS FUNCIONES "VAN AL FINAL"
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

SET PWD=%CD%


IF /I "%~1"=="-H"     GOTO HELP
IF /I "%~1"=="--HELP" GOTO HELP

ECHO Verificando sistema

:: Chequear programas

wsl -l > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   ECHO FALTA WSL
   exit /b 32
)   

: Chequear que es WSL 2

wsl --update > \\.\NUL 2> \\.\NUL
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
SETX /s %COMPUTERNAME% /U %USERNAME% WSL_MACHINES_DRIVE %ROOT% > \\.\NUL 2> \\.\NUL

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
GOTO :END

:HELP
   ECHO  Prepara y verifica el sistema Windows para usart WSL
   ECHO %0 [virtual_drive]
   ECHO     virtual_drive - Disco virtual donde se guardaran las distros y su informacion
   ECHO    wsl_source  Imagen a partir de la que se va a crear
   ECHO    %BOLD%Por defecto se asume M: %NC%
   GOTO END
   
   

:END 
   EXIT /B %RC%
