@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log11.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 11 %date% %time% > "%LOG%"
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo citesc ce s-a optimizat la pornire...
%ADB% %S% shell "uptime; getprop dalvik.vm.dex2oat-flags; logcat -d -v time | grep -E 'Running dexopt|dex2oat took|F/dex2oat|DexOptimizer.*(fail|error)|performBootDexOpt|Optimizing' | tail -30; ls -l /data/app; ls -l /data/app/*/oat/*/*; dumpsys package com.google.android.gms | grep -E 'versionName|lastUpdateTime'" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
