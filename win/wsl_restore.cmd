:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script para restaurar un backup de WSL
::
:: Se asume la estructura definida en wsl_env
::
:: Options:
::   --name     La distro a restaurar
::   --label    etiqueta adicional usada para el backup
::   --file     Copai de seguridad a recuperar
::
:: History 
::   v1 - Pasa del choose, coge la ultima
::
:: Este software se distribuye de acuerdo con la licencia/EULA MIT
:: Ver LICENSE para mas informacion (en ingles)
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

SET SRC=
SET LBL=
SET BCK=
SET TPL=
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

SET BCK=%WSL2_MACHINES_DRIVE%\backups
SET FLOG=%SHR%\logs\%~n0.log

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

SET FRESTORE=%WRKTMP%\%PRFXWSL%restore.txt

IF DEFINED BCK SET BCKFILE=%BCK: =%
IF DEFINED BCK ECHO %BCKFILE% > %FRESTORE%
IF DEFINED BCK GOTO :PREDIR

SET TPL=%SRC: =%

IF DEFINED LBL SET TPL=%TPL%_%LBL: =%

:: Guardar los nombres de los backups en un fichero

DIR /B /OD %BCK%\%TPL%* > %FRESTORE% 2> \\.\NUL
IF %ERRORLEVEL% NEQ 0 (
   CALL :INFO No hay copias de seguridad disponibles para los criterios indicados
   EXIT /B 4
)

:: Chequear si hay uno o mas
SET FCOUNT=%WRKTMP%\%PRFXWSL%count.txt
%BIN%\wc -l %FRESTORE% > %FCOUNT%
SET /A COUNTER=0
FOR /F "tokens=1" %%A IN (%FCOUNT%) DO SET /A COUNTER=%%A

:: Si hay varios seleccionar
SET FOUND=0
IF %COUNTER% EQU 1 FOR /F "tokens=*" %%A IN (%FRESTORE%) DO SET BCKFILE=%%A
IF %COUNTER% GTR 1 CALL :SELECT_ITEM

:PREDIR
:: Forzar a parar la distro, esperando si es necesario
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

CALL :PROGRESS Restaurando %BCKFILE%

SET WRKFILE=%PRFXTMP%%BCKFILE%
COPY /Y %BCK%\%BCKFILE% %WRKTMP%\%WRKFILE%  > \\.\NUL 2> \\.\NUL


%SystemDrive%
CD %WRKTMP%

ECHO %WRKFILE% | %BIN%\grep -q "tar\.gz"

IF NOT %ERRORLEVEL% EQU 0 GOTO :MAKETAR

CALL :PROGRESS Descomprimiendo

%BIN%\gzip -qfd %WRKFILE%         
IF %ERRORLEVEL% NEQ 0 (
   CALL :ERR No se ha podido descopmprimir el archivo
   EXIT /B 12
)

echo %WRKFILE% | %BIN%\sed s/\.gz//g > %FRESTORE%
SET /P WRKFILE=< %FRESTORE%

:MAKETAR
   CALL :PROGRESS Restaurando

   CD %WRKTMP%
   :: Ojo con las rutas en el tar (/\\ etc)
   %BIN%\tar -xf %WRKFILE%

   IF %ERRORLEVEL% NEQ 0 (
      CALL :ERR Ha ocurrido un error al restaurar la copia de seguridad
      SET RC=12
      GOTO :END
   )      

   XCOPY /E /C /I /Q /H /R /Y %WRKTMP%\%SRC% %WSL2_MACHINES_DRIVE%\%SRC%  > \\.\NUL 2> \\.\NUL

   IF %ERRORLEVEL% NEQ 0 (
      CALL :ERR Ha ocurrido un error al mover la copia de seguridad   
      SET RC=12
   )      
   
GOTO :END

:SELECT_ITEM
   :SELECT_ITEM_LOOP
   SET /A COUNTER=1
   FOR /F "tokens=*" %%A IN (%FRESTORE%) DO CALL :LISTAR %%A
   SET /P ITEM="Seleccione el numero de la copia de seguridad deseada: "

   SET /A COUNTER=1
   FOR /F "tokens=*" %%A IN (%FRESTORE%) DO CALL :SELECT %%A
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
   
:PROGRESS
  echo %GREEN%%T% - %* %NC% | %BIN%\tee -a %FLOG%
  GOTO :EOF
  
:INFO
  echo %WARN%%T% - %* %NC%  | %BIN%\tee -a %FLOG%
  GOTO :EOF
:ERR
  ECHO %RED%%T% - %* %NC% 1>&2  | %BIN%\tee -a %FLOG%
  GOTO :EOF

:HELP
   ECHO Recupera una copia de seguridad de una distro
   ECHO %0 --name nombre [--label label] [--file backup_file]
   ECHO    --name nombre: Nombre de la distro segun WSL
   ECHO    --label label: Etiqueta opcional para el backup  
   ECHO    --file backup_file Especifica el backup concreto a recuperar 
   GOTO END2
   
:END 
   DEL /S /Q %WRKTMP%\sed*         > \\.\NUL 2> \\.\NUL
   DEL /S /Q %WRKTMP%\%PRFXWSL%*   > \\.\NUL 2> \\.\NUL
   DEL /S /Q %WRKTMP%\%PRFXTMP%*   > \\.\NUL 2> \\.\NUL   
   RD  /S /Q %WRKTMP%\%SRC%
   %CWD:~0,2%
   CD %CWD%
:END2   
   EXIT /B %RC%
