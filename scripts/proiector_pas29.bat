@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log29.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 29 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% logcat -c
echo astept 60 de secunde cat incearca home assistant sa se conecteze...
timeout /t 60 /nobreak
%ADB% %S% shell "getprop ro.adb.secure; getprop service.adb.tcp.port; cat /data/misc/adb/adb_keys | wc -l; logcat -d -v time | grep -iE 'adb|usbdebug' | tail -30; cat /proc/net/tcp6 /proc/net/tcp | grep -i ':15B3'" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA.
pause
