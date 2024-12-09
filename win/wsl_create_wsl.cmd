:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para crear maquina una maquina a partir de otra
:: 
:: Parametros
:: --from name  - Maquina base
:: --name name  - Maquina destino
:: --force      - Si se especifica crea una maquina desde cero
::                Si no, mantiene configuracion existente 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

SET WSL_SRC=base
SET WSL_TGT=
SET FORCE=0

SET mypath=%~dp0
SET DIR=%mypath:~0,-1%

CALL %DIR%\wsl_common_win
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de datos comunes
   exit /b 16
)   

CALL %DIR%\wsl_env
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de variables de entorno wsl_env
   exit /b 16
)   

:: NO SE HACE CONTROL DE ERRORES
:: YA FALLARA POR ALGUN OTRO SITIO

:GETOPTS
   IF /I  "%~1" == "-H"       GOTO HELP
   IF /I  "%~1" == "--HELP"   GOTO HELP
   IF /I  "%1"  == "--from"   SET WSL_SRC=%2 & shift
   IF /I  "%1"  == "--name"   SET WSL_TGT=%2 & shift
   IF /I  "%1"  == "--force"  SET FORCE=1    & shift
   IF NOT "%1"  == ""         SET WSL_TGT=%1 & shift
   SHIFT
   IF NOT "%1" == "" goto GETOPTS

IF "%WSL_TGT%" == "" (
   ECHO %ERR%No se ha indicado el nombre de la maquina%NC%
   exit /b 16
)

WSL --unregister %WSL_TGT% > \\.\NUL 2> \\.\NUL
IF %FORCE% EQU 1 RD /S /Q %WSL_MACHINES_DRIVE%\%WSL_TGT% > \\.\NUL 2> \\.\NUL

CALL :PROGRESS Exportando distro: %WSL_SRC%
WSL --export %WSL_SRC% %TMP%/wsl.tar > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha podido exportar la maquina %WSL_SRC% (Existe?)
if %RC%         NEQ 0 GOTO :END

CALL :PROGRESS Generando distro: %WSL_TGT%
MD   %WSL_MACHINE_DRIVE%\%WSL_TGT% > \\.\NUL 2> \\.\NUL
WSL --import %WSL_TGT% %WSL_MACHINES_DRIVE%\%WSL_TGT% %TMP%\wsl.tar > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha podido importar la maquina %WSL_TGT%
if %RC%         NEQ 0 GOTO :END

CALL :PROGRESS Limpiando
DEL /S /Q /F %TMP%\wsl.tar > \\.\NUL 2> \\.\NUL

exit /b 0
  
:PROGRESS
  echo %GREEN%%T% - %* %NC%
  GOTO :EOF

:ERR
  SET RC=%1
  SHIFT
  ECHO %RED%%T% - %* %NC% 1>&2
  ECHO %0 >> %LOG% 
  GOTO :END

:HELP
   ECHO %0 wsl_target [wsl_WSL_SRC]
   ECHO    wsl_target  Nombre de la distro WSL a crear
   ECHO    wsl_WSL_SRC  Imagen a partir de la que se va a crear
   ECHO    %BOLD%Nota: Se asume que el disco virtual de maquinas es M: %NC%
   GOTO END
   
:END 
   EXIT /B %RC%

