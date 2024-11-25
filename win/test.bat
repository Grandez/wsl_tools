:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
: Script para crear maquina
:
:
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



CALL :PROGRESS Exportando maquina base (%WSL_SRC%)
CALL :PROGRESS1 Exportando maquina base (%WSL_SRC%)
CALL :PROGRESS2 Exportando maquina base (%WSL_SRC%)
echo sigo 

:END 
echo salgo
EXIT /B

:PROGRESS
  echo %GREEN%%time% - Exportando maquina base %NC%
GOTO :eof

:PROGRESS1
  echo %GREEN%%time% - Exportando maquina base1 %NC%
GOTO :eof
:PROGRESS2
  echo %GREEN%%time% - Exportando maquina base2 %NC%
GOTO :eof
