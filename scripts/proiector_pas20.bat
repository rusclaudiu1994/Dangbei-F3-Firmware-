@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log20.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 20 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
echo instalez SmartTube (~35 mb, ~1 minut)...
%ADB% %S% install -r "%~dp0SmartTube.apk" >> "%LOG%" 2>&1
%ADB% %S% shell "dumpsys package org.smarttube.stable | grep versionName" >> "%LOG%" 2>&1
echo pornesc SmartTube pe proiector...
%ADB% %S% shell "monkey -p org.smarttube.stable -c android.intent.category.LEANBACK_LAUNCHER 1 || monkey -p org.smarttube.stable -c android.intent.category.LAUNCHER 1" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
