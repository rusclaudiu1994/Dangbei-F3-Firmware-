@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log26.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 26 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo citesc partitia MPOOL (doar citire)...
%ADB% %S% shell "cat /proc/partitions; dd if=/dev/block/platform/mstar_mci.0/by-name/MPOOL of=/sdcard/bk/MPOOL.img bs=1048576 2>&1 | tail -1; ls -l /sdcard/bk/MPOOL.img" >> "%LOG%" 2>&1
%ADB% %S% pull /sdcard/bk/MPOOL.img "%~dp0backup\bk\MPOOL.img" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
