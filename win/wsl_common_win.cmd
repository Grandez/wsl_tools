:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
: Variables de entorno de uso comun
:
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET RC=0
SET NC=[0m 
SET BOLD=[1m
SET GREEN=[32m
SET BLUE=[1;34m
SET RED=[31m

SET INFO=%GREEN%
SET WARN=%BLUE%
SET ERR=%RED%


SET T=%TIME:~0,8%
SET LOG=%TEMP%\wsl.log

:GETOPTS
   IF /I "%~1"== "-H"      GOTO HELP
   IF /I "%~1"== "--HELP"  GOTO HELP

SET DISTRO=%1
IF NOT "%1" == "" SET LOG=%TEMP%\%DISTRO%.log


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


