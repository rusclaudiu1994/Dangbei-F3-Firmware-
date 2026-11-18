@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log5.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 5 %date% %time% > "%LOG%"
echo astept sa porneasca proiectorul de tot...
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo citesc jurnalul de pornire...
echo --- uptime >> "%LOG%"
%ADB% %S% shell "uptime; getprop | grep -E 'dalvik.vm|pm.dexopt|ro.build.date'" >> "%LOG%" 2>&1
echo --- dexopt log >> "%LOG%"
%ADB% %S% shell "logcat -d -v time | grep -iE 'dex2oat|dexopt|DexOptimizer|optimiz|performBootDexOpt|PackageManager.*(fail|error|warn)|Installer' | head -300" >> "%LOG%" 2>&1
echo --- data/app >> "%LOG%"
%ADB% %S% shell "ls -l /data/app; ls -l /data/app/*/oat/*" >> "%LOG%" 2>&1
echo --- dalvik-cache >> "%LOG%"
%ADB% %S% shell "ls -l /data/dalvik-cache/arm64 | grep -v '@system@framework' | head -80; ls /data/dalvik-cache/arm64 | grep -c ." >> "%LOG%" 2>&1
echo --- packages.xml dexopt >> "%LOG%"
%ADB% %S% shell "ls -l /data/system/package-usage.list /data/system/packages.xml" >> "%LOG%" 2>&1
echo --- wifi >> "%LOG%"
%ADB% %S% shell "dumpsys wifi | grep -iE 'mWifiInfo|rssi|linkspeed|frequency' | head -5" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
