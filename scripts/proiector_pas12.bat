@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log12.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 12 %date% %time% > "%LOG%"
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo reglez ora automata...
echo --- inainte >> "%LOG%"
%ADB% %S% shell "date; uptime; settings get global auto_time; settings get global auto_time_zone; settings get global ntp_server; getprop persist.sys.timezone; getprop ro.ntp.server; ls /dev/rtc* 2>&1; cat /sys/class/rtc/rtc0/date /sys/class/rtc/rtc0/time 2>&1; logcat -d -v time | grep -iE 'NetworkTimeUpdate|SntpClient|ntp' | tail -15" >> "%LOG%" 2>&1
echo --- setari >> "%LOG%"
%ADB% %S% shell "settings put global auto_time 1; settings put global auto_time_zone 0; settings put global ntp_server ro.pool.ntp.org; setprop persist.sys.timezone Europe/Bucharest; settings get global auto_time; settings get global ntp_server; getprop persist.sys.timezone" >> "%LOG%" 2>&1
echo --- ora acum >> "%LOG%"
timeout /t 20 /nobreak >nul
%ADB% %S% shell "date; logcat -d -v time | grep -iE 'NetworkTimeUpdate|SntpClient|ntp' | tail -10" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
