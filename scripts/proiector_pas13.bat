@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log13.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 13 %date% %time% > "%LOG%"
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo verific sincronizarea orei...
%ADB% %S% shell "date; uptime; settings get global auto_time; settings get global ntp_server; dumpsys network_time_update_service; ping -c 2 ro.pool.ntp.org; ping -c 2 time.google.com; ls /system/xbin; ls /system/bin | grep -iE 'busybox|toybox|ntp|rdate|wget|curl|nc$'; logcat -d -v time | grep -E 'NetworkTimeUpdate|SntpClient|NtpTrustedTime|AlarmManager.*time|setTime|TimeSet' | tail -20; ps | grep -iE 'time|ntp|dangs'" >> "%LOG%" 2>&1
echo --- logcat optimizare >> "%LOG%"
%ADB% %S% shell "logcat -d -v time | grep -E 'Running dexopt|dex2oat took' | tail -5" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
