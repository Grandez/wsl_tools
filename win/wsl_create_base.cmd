:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para crear maquina la maquina base
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
echo ejecutando wsl_create_base
SET WSL_SRC=Ubuntu-24.04
SET WSL_TGT=base
SET FORCE=1

SET mypath=%~dp0
SET DIR=%mypath:~0,-1%

CALL %DIR%\wsl_env
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de variables de entorno wsl_env
   exit /b 16
)   
CALL %DIR%\wsl_common_win

:: NO SE HACE CONTROL DE ERRORES, YA FALLARA POR ALGUN OTRO SITIO

:GETOPTS
   IF /I "%~1"== "-H"      GOTO HELP
   IF /I "%~1"== "--HELP"  GOTO HELP
   IF /I "%1" == "--from"  SET WSL_SRC=%2 & shift
   IF /I "%1" == "--name"  SET WSL_TGT=%2 & shift
   IF /I "%1" == "-f"      SET WSL_SRC=%2 & shift
   IF /I "%1" == "-n"      SET WSL_TGT=%2 & shift
   SHIFT
   IF NOT "%1" == "" goto GETOPTS

REM Actualizamos WSL  
CALL :PROGRESS Actualizando WSL
WSL --update > \\.\NUL 2> \\.\NUL

CALL :INFO     Cuando se le pregunte introduzca su usuario y password
CALL :INFO     Cuando se inicie el shell teclee: %NC%%BOLD%sudo passwd%NC%
CALL :INFO     Establezca la password de root
CALL :INFO     teclee %NC%%BOLD%exit%NC%%WARN% para continuar%NC%

WSL --install    %WSL_SRC% 
IF %ERRORLEVEL% NEQ 0 (
   ECHO No se ha podido descargar la distro %WSL_SRC%
   exit /b 32
)   

REM Copiamos los scripts a TEMP de windows (ese no falla)
COPY /Y /V /B %WSL_MACHINES_DRIVE%\shared\wsl_tools\wsl*               c:\windows\Temp > \\.\NUL 2> \\.\NUL
COPY /Y /V /B %WSL_MACHINES_DRIVE%\shared\wsl_tools\win\wsl_env.cmd    c:\windows\Temp > \\.\NUL 2> \\.\NUL
echo SET WSL_DISTRO_NAME=%WSL_TGT% >> c:\windows\Temp\wsl_env.sh

IF %ERRORLEVEL% NEQ 0 CALL :ERR 1 No se han podido preparar los scripts de ejecucion
if %RC%         NEQ 0 GOTO :END

REM Llamamos al script generico de crear maquinas que controla la maquina base

SET MODO=--clean
IF %FORCE% EQU 0 SET MODO=--keep
CALL %DIR%\wsl_create_wsl  --from %WSL_SRC% --name %WSL_TGT% %MODO% 
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

WSL --unregister %WSL_SRC% > \\.\NUL 2> \\.\NUL


CALL :PROGRESS Proceso realizado
CALL :INFO Se recomienda reiniciar WSL (wsl --shutdown)

SET RC=%ERRORLEVEL%
exit /b RC

:PROGRESS
  echo %GREEN%%T% - %* %NC%
  GOTO :EOF
:INFO
  echo %WARN%%T% - %* %NC%
  GOTO :EOF
:ERR
  SET RC=%1
  SHIFT
  ECHO %RED%%T% - %* %NC% 1>&2
  ECHO %0 >> %LOG% 
  GOTO :END
:HELP
   ECHO Crea la distro base
   ECHO %0 wsl_create_base [--name nombre] [--from distro_name]
   ECHO    --name nombre: Nombre de la maquina base. Por defecto: %BOLD%base%NC%
   ECHO    --from distro_name: Origen de la distro del Store. Por defecto: %BOLD%Ubuntu-24.04%NC%
   ECHO    %BOLD%Nota: Se asume que el disco virtual de maquinas es M: %NC%
   GOTO END
   
:END 
   EXIT /B %RC%
