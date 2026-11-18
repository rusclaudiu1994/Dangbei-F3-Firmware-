@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log21.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 21 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
echo sterg datele youtube-ului vechi si cardurile de pe ecranul principal...
%ADB% %S% shell "pm clear com.google.android.youtube.tv" >> "%LOG%" 2>&1
%ADB% %S% shell "am force-stop com.dangbei.tvlauncher; input keyevent 3" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. uita-te pe ecranul principal.
pause
