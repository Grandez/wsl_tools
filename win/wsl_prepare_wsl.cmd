:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para crear maquina la maquina base
:: LAS FUNCIONES "VAN AL FINAL"
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

SET SOURCE=Ubuntu-24.04
SET BASE=base
SET FORCE=0
SET LOG=%TMP%/%~n0.log
SET WSL_SRC=%SOURCE%
:: SET "WSL_MACHINES_DRIVE=%WSL_MACHINES_DRIVE%"
SET WSL_MACHINES_DRIVE=N

SET mypath=%~dp0
SET dir=%mypath:~0,-1%

IF /I "%~1"=="-H"     GOTO HELP
IF /I "%~1"=="--HELP" GOTO HELP

CALL %dir%\wsl_env
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de variables de entorno wsl_env
   exit /b 16
)   

IF /I "%WSL_MACHINES_DRIVE%" == ""  (
   ECHO No existe la variable de entrono WSL_MACHINES_DRIVE
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

CALL :PROGRESS Obteniendo distro del Store
wsl --install %SOURCE% 
IF %ERRORLEVEL% NEQ 0 (
   ECHO No se ha podido descargar la distro %SOURCE%
   exit /b 32
)   

SET WSL_TGT=%BASE%

CALL :PROGRESS Exportando distro: %WSL_SRC%
WSL --export %WSL_SRC% %TMP%/wsl.tar >> %LOG% 2>&1
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha podido exportar la maquina %WSL_SRC% (Existe?)
if %RC%         NEQ 0 GOTO :END

CALL :PROGRESS Generando distro: %BASE%
WSL --unregister %WSL_TGT% >> %LOG% 2>&1
RD /Q /S %MACHINE_DRIVE%\%WSL_TGT%  > \\.\NUL 2> \\.\NUL
MD   %MACHINE_DRIVE%\%WSL_TGT%      > \\.\NUL 2> \\.\NUL

WSL --import %WSL_TGT% %MACHINE_DRIVE%\%WSL_TGT% %TMP%\wsl.tar >> %LOG% 2>&1
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha podido importar la maquina %WSL_TGT%
if %RC%         NEQ 0 GOTO :END

CALL :PROGRESS Limpiando
DEL /S /Q /F %TMP%\wsl.tar > \\.\NUL 2> \\.\NUL

CALL :PROGRESS Configurando distro
XCOPY %WSL_MACHINES_DRIVE%:\Shared\wsl_tools %windir%\Temp /s /e /h > \\.\NUL 2> \\.\NUL
:: Esto puede fallar si no es c:\Windows
WSL -d %WSL_TGT% --exec /mnt/c/Windows/Temp/wsl_base_launcher.sh

CALL :PROGRESS Hecho
GOTO END

:CLEAN
   wsl --unregister %SOURCE% > \\.\NUL 2> \\.\NUL
   wsl --unregister %BASE%   > \\.\NUL 2> \\.\NUL
   GOTO :EOF
  
:PROGRESS
   echo %INFO%%T% - %* %NC%
   GOTO :EOF

:NOPARM
   echo %RED%%T% - Falta el nombre de la maquina a crear %NC% 1>&2
   GOTO :END

:ERR
   SET RC=%1
   SHIFT
   ECHO %ERR%%T% - %* %NC% 1>&2
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
