: @echo off
:
: Crea los accesos directos para arrancar y parar WSL
:

SET PWS=powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile
SET WSS=$ws = New-Object -ComObject WScript.Shell;
SET LNK1=$s = $ws.CreateShortcut('%USERPROFILE%\Desktop\wsl start.lnk');
SET LNK2=$s = $ws.CreateShortcut('%USERPROFILE%\Desktop\wsl stop.lnk');
SET TGT1=$S.TargetPath = '%cd%\wsl_geiser_start.cmd';
SET TGT2=$S.TargetPath = '%cd%\wsl_geiser_stop.cmd';

SET CWD=$s.WorkingDirectory = '%cd%';
SET ICO1=$s.IconLocation = '%cd%\wsl_geiser_start.ico';
SET ICO2=$s.IconLocation = '%cd%\wsl_geiser_stop.ico';
SET TXT=$s.Description = 'Lanzador de las instancias WSL para Geiser';
SET STY=$s.WindowStyle = 7;
SET SAV=$s.Save();

SET CMD1=%LNK1% %TGT1% %ICO1% %CWD% %TXT% %STY% %SAV% 
SET CMD2=%LNK2% %TGT2% %ICO2% %CWD% %TXT% %STY% %SAV% 
SET TAIL=%CWD% %TXT% %STY% %SAVE%

%PWS% -Command "%WSS% %CMD1% %TAIL%"
%PWS% -Command "%WSS% %CMD2% %TAIL%"

