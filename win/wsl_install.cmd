:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para descargar maquinas segun arquitectura
::
:: Requiere:
::   wsl_common_win
::   wsl_env  (Creado con wsl_prepare_win)
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

: @ECHO OFF

SET SCRB=%~dp0
SET SCRN=%~n0
SET BASEDIR=%SCRB:~0,-1%

CALL %BASEDIR%\wsl_env
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de variables de entorno wsl_env
   exit /b 16
)   
CALL %BASEDIR%\wsl_common_win %SCRN%
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de general wsl_common_win
   exit /b 16
)   

:: NO SE HACE CONTROL DE ERRORES, YA FALLARA POR ALGUN OTRO SITIO

:GETOPTS
   IF /I "%~1"== "-H"      GOTO HELP
   IF /I "%~1"== "--HELP"  GOTO HELP

SET DISTRO=%1
IF "%DISTRO%" == "" (
    CALL :ERR Falta la distribucion a descargar
    GOTO :END
)

RD /S /Q %WSL2_MACHINES_DRIVE%\%DISTRO% > \\.\NUL 2> \\.\NUL
MD       %WSL2_MACHINES_DRIVE%\%DISTRO% > \\.\NUL 2> \\.\NUL
WSL --install %DISTRO% --location %WSL2_MACHINES_DRIVE%\%DISTRO%
IF %ERRORLEVEL% NEQ 0 GOTO END


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
   ECHO Descarga una distro de Microsoft Store
   ECHO %0 distro_name
   ECHO     distro_name debe ser una de las listadas con %BOLD%wsl -l --online%NC%
   GOTO END
   
:END 
   EXIT /B %RC%
