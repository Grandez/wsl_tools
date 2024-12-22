:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para restaurar un backup de WSL
::
:: Se asume la estructura definida en wsl_env
::
:: Options:
::   --name     La distro a restaurar
::   --choose   Permite elegir la copia de seguridad
::
:: History 
::   v1 - Pasa del choose, coge la ultima
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

SET SRC=
SET LBL=
SET BCK=
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
   IF /I "%1" == "--file"     SET BCK=%2  & shift      
   SHIFT
   IF NOT "%1" == "" goto GETOPTS

IF NOT DEFINED SRC (
   CALL :ERR No se ha indicado el nombre de la distro
   EXIT /B 16
)   

IF DEFINED SRC SET SRC=%SRC: =%
IF DEFINED LBL SET LBL=%LBL: =%
IF DEFINED BCK (
   SET TPL=%BCK: =%
) ELSE (
  SET TPL=%SRC%_wsl
  IF DEFINED LBL SET TPL=%TPL%_%LBL%
)

:: Guardar los nombres delos backups en un fichero
DIR /B /OD %SHR%\backups\%TPL%* > %WRKTMP%\wsl_tmp_restore.txt
IF %ERRORLEVEL% NEQ 0 (
   CALL :INFO No hay copias de seguridad disponibles para los criterios indicados
   EXIT /B 4
)

:: Chequear si hay uno o mas
%BIN%\wc -l %WRKTMP%\wsl_tmp_restore.txt > %WRKTMP%\wsl_tmp_count.txt
SET /A COUNTER=0
FOR /F "tokens=1" %%A IN (%WRKTMP%\wsl_tmp_count.txt) DO SET /A COUNTER=%%A

:: Si hay varios seleccionar
SET FOUND=0
IF %COUNTER% EQU 1 FOR /F "tokens=*" %%A IN (%WRKTMP%\wsl_tmp_restore.txt) DO SET BCKFILE=%%A
IF %COUNTER% GTR 1 CALL :SELECT_ITEM

:: Forzar a parar la distro, ezperando si es necesario
WSL --terminate %SRC% > \\.\NUL 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   CALL :ERR  No existe la distro %SRC%
   EXIT /B 16
)   

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

CALL :PROGRESS Restaurando %SRC% a partir de %BCKFILE%
COPY /Y %SHR%\backups\%BCKFILE% %WRKTMP%\wsl_tmp_%BCKFILE%  > \\.\NUL 2> \\.\NUL

SET BCKFILE=%WRKTMP%\wsl_tmp_%BCKFILE% 
%SystemDrive%
CD %WRKTMP%

ECHO %BCKFILE% > %BIN%\grep "tar\.gz"

IF %ERRORLEVEL% EQU 0 (
   CALL :PROGRESS Descomprimiendo
   %BIN%\gzip -qfd %BCKFILE%
   ECHO %BCKFILE% | %BIN%/sed s/\.gz// > %WRKTMP%\wsl_tmp_restore.txt
   SET /p BCKFILE=< %WRKTMP%\wsl_tmp_restore.txt
)

CALL :PROGRESS Restaurando
%BIN%\tar --extract --directory=%SHR% --file %BKFILE%

GOTO :END

:SELECT_ITEM
   :SELECT_ITEM_LOOP
   SET /A COUNTER=1
   FOR /F "tokens=*" %%A IN (%WRKTMP%\wsl_tmp_restore.txt) DO CALL :LISTAR %%A
   SET /P ITEM="Seleccione el numero de la copia de seguridad deseada: "

   SET /A COUNTER=1
   FOR /F "tokens=*" %%A IN (%WRKTMP%\wsl_tmp_restore.txt) DO CALL :SELECT %%A
   ECHO SALE DEL FOR CON %FOUND%
   IF %FOUND% EQU 0 (
      CALL :INFO Seleccion incorrecta %ITEM%
      GOTO :SELECT_ITEM_LOOP
   )
   GOTO :EOF
   
:SELECT
   IF %COUNTER% EQU %ITEM% (
      SET BCKFILE=%1
      SET FOUND=1
   )
   SET /A COUNTER=%COUNTER% + 1
   GOTO :EOF  

:LISTAR 
  ECHO [%COUNTER%] - %1
  SET /A COUNTER=%COUNTER% + 1
  GOTO :EOF
   
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
   ECHO Recupera una copia de seguridad de una distro
   ECHO %0 --name nombre [--label label] [--file backup_file]
   ECHO    --name nombre: Nombre de la distro segun WSL
   ECHO    --label label: Etiqueta opcional para el backup  
   ECHO    --file backup_file Especifica el backup concreto a recuperar 
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
   DEL /Y %WRKTMP%\wsl_tmp*
   %CWD:~0,2%
   CD %CWD%
   EXIT /B %RC%
