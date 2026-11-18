@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log22.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 22 %date% %time% > "%LOG%"
echo astept proiectorul...
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
echo instalez Home Assistant (~55 mb, 1-2 minute)...
%ADB% %S% install -r "%~dp0HomeAssistant_minimal.apk" >> "%LOG%" 2>&1
%ADB% %S% shell "dumpsys package io.homeassistant.companion.android.minimal | grep versionName" >> "%LOG%" 2>&1
echo pornesc Home Assistant pe proiector...
%ADB% %S% shell "monkey -p io.homeassistant.companion.android.minimal -c android.intent.category.LEANBACK_LAUNCHER 1" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
