:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para crear maquina la maquina base
:: LAS FUNCIONES "VAN AL FINAL"
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

SET SOURCE=Ubuntu-24.04
SET BASE=base
SET FORCE=0

SET mypath=%~dp0
SET dir=%mypath:~0,-1%

IF /I "%~1"=="-H"     GOTO HELP
IF /I "%~1"=="--HELP" GOTO HELP

CALL %dir%\wsl_env
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de variables de entorno wsl_env
   exit /b 16
)   

:: NO SE HACE CONTROL DE ERRORES
:: YA FALLARA POR ALGUN OTRO SITIO

:GETOPTS
 IF /I "%1" == "--from"  SET SOURCE=%2 & shift
 IF /I "%1" == "--name"  SET BASE=%2   & shift
 IF /I "%1" == "--force" SET FORCE=1   & shift
 SHIFT
 IF NOT "%1" == "" goto GETOPTS

IF %FORCE% EQU 1 CALL :CLEAN

CALL :PROGRESS Actualizando WSL
wsl --update > \\.\NUL 2> \\.\NUL

CALL :PROGRESS Obteniendo distro del Store
wsl --install %SOURCE% > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   ECHO No se ha podido descargar la distro %SOURCE%
   exit /b 32
)   

echo BASE %BASE%
echo SOURCE %SOURCE%
echo FIRCE %FORCE%

exit /b 3



SET LOG=%TMP%/%~n0.log
SET WSL_SRC=base

IF "%~1"=="" GOTO NOPARM
IF /I "%~1"=="-H"     GOTO HELP
IF /I "%~1"=="--HELP" GOTO HELP

ECHO. > %LOG%

SET WSL_TGT=%~1

IF NOT "%~2"=="" SET WSL_SRC="%~2"

CALL :PROGRESS Exportando distro: %WSL_SRC%
WSL --export %WSL_SRC% %TMP%/wsl.tar >> %LOG% 2>&1
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha podido exportar la maquina %WSL_SRC% (Existe?)
if %RC%         NEQ 0 GOTO :END

CALL :PROGRESS Generando distro: %WSL_TGT%
WSL --unregister %WSL_TGT% >> %LOG% 2>&1
RD /Q /S %MACHINE_DRIVE%\%WSL_TGT%
MD   %MACHINE_DRIVE%\%WSL_TGT%

WSL --import %WSL_TGT% %MACHINE_DRIVE%\%WSL_TGT% %TMP%\wsl.tar >> %LOG% 2>&1
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha podido importar la maquina %WSL_TGT%
if %RC%         NEQ 0 GOTO :END

CALL :PROGRESS Configurando distro
: Aqui ejecutamos los scripts

CALL :PROGRESS Limpiando
DEL /S /Q /F %TMP%\wsl.tar

CALL :PROGRESS Hecho


GOTO END

:CLEAN

  wsl --unregister %SOURCE% 2> \\.\NUL
  wsl --unregister %BASE%   2> \\.\NUL
  GOTO :EOF
  
:PROGRESS
  echo %GREEN%%T% - %* %NC%
  GOTO :EOF

:NOPARM
   echo %RED%%T% - Falta el nombre de la maquina a crear %NC% 1>&2
   GOTO :END

:ERR
  SET RC=%1
  SHIFT
  ECHO %RED%%T% - %* %NC% 1>&2
  ECHO %0 >> %LOG% 
  GOTO :END

:HELP
   ECHO %0 wsl_target [wsl_source]
   ECHO    wsl_target  Nombre de la distro WSL a crear
   ECHO    wsl_source  Imagen a partir de la que se va a crear
   ECHO    %BOLD%Nota: Se asume que el disco virtual de maquinas es M: %NC%
   GOTO END
   
   

:END 
   EXIT /B %RC%
