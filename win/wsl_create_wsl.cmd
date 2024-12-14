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
SET WSL_TYP=
SET FORCE=1

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

:: NO SE HACE CONTROL DE ERRORES, YA FALLARA POR ALGUN OTRO SITIO

:GETOPTS
   IF /I  "%~1" == "-H"       GOTO HELP
   IF /I  "%~1" == "--HELP"   GOTO HELP
   IF /I  "%1"  == "--from"   SET WSL_SRC=%2 & shift
   IF /I  "%1"  == "--name"   SET WSL_TGT=%2 & shift
   IF /I  "%1"  == "--type"   SET WSL_TYP=%2 & shift
   IF /I  "%1"  == "--clean"  SET FORCE=1
   IF /I  "%1"  == "--keep"   SET FORCE=0
   SHIFT
   IF NOT "%1" == "" goto GETOPTS

SET WSL_SRC=%WSL_SRC: =%
SET WSL_TGT=%WSL_TGT: =%

IF "%WSL_TGT%" == "" (
   ECHO %ERR%No se ha indicado el nombre de la maquina%NC%
   exit /b 16
)

WSL --unregister %WSL_TGT% > \\.\NUL 2> \\.\NUL
IF %FORCE% EQU 1 RD /S /Q %WSL_MACHINES_DRIVE%\%WSL_TGT% > \\.\NUL 2> \\.\NUL

CALL :PROGRESS Exportando distro: %BOLD%%WSL_SRC%%NC%
WSL --export %WSL_SRC% %TMP%/wsl.tar > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha podido exportar la maquina %WSL_SRC% (Existe?)
if %RC%         NEQ 0 GOTO :END

CALL :PROGRESS Generando distro: %BOLD%%WSL_TGT%%NC%
MD   %WSL_MACHINES_DRIVE%\%WSL_TGT% & :: > \\.\NUL 2> \\.\NUL
WSL --import %WSL_TGT% %WSL_MACHINES_DRIVE%\%WSL_TGT% %TMP%\wsl.tar --version 2 > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha podido importar la maquina %WSL_TGT%
if %RC%         NEQ 0 GOTO :END

CALL :PROGRESS Limpiando
DEL /S /Q /F %TMP%\wsl.tar > \\.\NUL 2> \\.\NUL

REM Ejecutamos el script en la distro usando el profile root
CALL :PROGRESS Configurando %WSL_TGT%
SET SCRIPT=/mnt/s/wsl_tools/wsl_configure_wsl
IF /I "%WSL_TGT%" == "base" SET SCRIPT=/mnt/c/windows/temp/wsl_configure_base

WSL -d %WSL_TGT% -u root -- %SCRIPT% %WSL_TYP%
IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se ha ejecutado correctamente la fase de configuracion. Chequee wsl_configure_wsl.log

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
   ECHO Crea una distro a partir de una existente
   ECHO %0 --name distro_nueva [--from distro_base] [--clean] [--keep]
   ECHO    %BOLD%--from distro_base%NC%  - Nombre de la distro WSL a usar como plantilla. Por defecto %BOLD%base%NC%
   ECHO    %BOLD%--name distro_nueva%NC% - Nombre de la distro nueva
   ECHO    %BOLD%--type TIPO%NC% - Indica el tipo de distro a crear
   ECHO    %BOLD%--clean%NC% - Si la distro existe se borra toda la informacion (%BOLD%defecto%NC%)
   ECHO    %BOLD%--keep%NC%  - Si la distro existe se mantiene la confifuracion 
   GOTO END
   
:END 
   EXIT /B %RC%

