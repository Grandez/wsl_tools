:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para crear backups de distros WSL
::
:: Se asume la estructura definida en wsl_env
::
:: Options:
::   --label    para poner una etiqueta
::   --nozip    para no generarlo como gz
::   --nosuffix para no incluir la firma temporal
::
:: History 
::   v2 - Se hace copia de todo: maquina y datos en un unico archivo 
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

SET SRC=
SET LBL=
SET NOZIP=0
SET NOSFX=0
SET CWD=%CD%

SET mypath=%~dp0
SET DIR=%mypath:~0,-1%

CALL %DIR%\wsl_env
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de variables de entorno wsl_env
   exit /b 32
)   

CALL %DIR%\wsl_common_win
IF %ERRORLEVEL% NEQ 0 (
   ECHO Falta el script de variables generales
   exit /b 32
)   

SET SHR=%WSL2_MACHINES_DRIVE%\shared
SET TOOLS=%SHR%\wsl_tools
SET BIN=%TOOLS%\pkg

:GETOPTS
   IF /I "%~1"== "-H"         GOTO HELP
   IF /I "%~1"== "--HELP"     GOTO HELP
   IF /I "%1" == "--name"     SET SRC=%2  & shift
   IF /I "%1" == "--label"    SET LBL=%2  & shift   
   IF /I "%1" == "--nozip"    SET NOZIP=1 & shift
   IF /I "%1" == "--noSUFFIX" SET NOSFX=1 & shift   
   SHIFT
   IF NOT "%1" == "" goto GETOPTS

IF NOT DEFINED SRC (
   CALL :ERR No se ha indicado el nombre de la distro
   EXIT /B 16
)   

SET SRC=%SRC: =%

WSL --terminate %SRC% > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   CALL :ERR  No existe la distro %SRC%
   EXIT /B 16
)   

:: Esperar que termine efectivamente 

SET COUNTER=0
:WAITING
wsl -l -v | %BIN%\iconv -f UTF-16LE -t UTF-8 | %BIN%\grep %SRC% | %BIN%\grep -q topped
IF %ERRORLEVEL% NEQ 0 (
   TIMEOUT /T 1 /NOBREAK
   SET /A COUNTER=COUNTER+1
   IF %COUNTER% LEQ 10 GOTO :WAITING
)

wsl -l -v | %BIN%\iconv -f UTF-16LE -t UTF-8 | %BIN%\grep %SRC% | %BIN%\grep -q topped
IF %ERRORLEVEL% NEQ 0 (
   CALL :ERR  Parece que no se ha podido detener la distro %SRC%
   EXIT /B 16
)

CALL :PROGRESS Haciendo backup de la distro %SRC%
CALL :SET_NAME

SET FLG=-c -f
:: IF %NOZIP% EQU 0 SET FLG=%FLG%z
%WSL2_MACHINES_DRIVE%
CD \
SET CMD=%BIN%\tar

CALL :PROGRESS Generando
%CMD% %FLG: =%%FNAME% %SRC% 

IF %NOZIP% EQU 0 (
    CALL :PROGRESS Comprimiendo
    %BIN%\gzip %FNAME%
)
GOTO :END

:SET_NAME
   SET FNAME=/shared/backups/%SRC: =%_wsl
   IF DEFINED LBL SET FNAME=%FNAME%_%LBL: =%
   IF %NOSFX% EQU 0 (
      CALL :SETDATE
      SET FNAME=%FNAME%_%TMS%   
   )
   SET FNAME=%FNAME: =%.tar
   GOTO :EOF

:HELP
   ECHO Crea un backup de una distro
   ECHO %0 --name nombre [--label label] [--nozip] [--nosuffix]
   ECHO    --name nombre: Nombre de la distro segun WSL
   ECHO    --label label: Etiqueta opcional para el backup  
   ECHO    --nozip Por defecto el backup es comprimido
   ECHO    --nosuffix Por defecto el backup llevara el timestap de creacion
   ECHO    %BOLD%Nota: Se asume que el disco virtual de maquinas es %WSL2_MACHINES_DRIVE% %NC%
   GOTO END

:SETDATE
  SET YYYYMMDD=%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%
  SET HHMMSS=%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
  SET TMS=%YYYYMMDD%%HHMMSS%
  GOTO :EOF

:PROGRESS
  echo %GREEN%%T% - %* %NC%
  GOTO :EOF
:INFO
  echo %WARN%%T% - %* %NC%
  GOTO :EOF
:ERR
  ECHO %RED%%T% - %* %NC% 1>&2
  GOTO :EOF
   
:END 
   %CWD:~0,2%
   CD %CWD%
   EXIT /B %RC%
