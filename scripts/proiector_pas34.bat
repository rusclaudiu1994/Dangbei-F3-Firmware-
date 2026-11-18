@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log34.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 34 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/3 instalez touchpad-ul pe proiector...
%ADB% %S% push "%~dp0touchpadd" /data/local/tmp/touchpadd >> "%LOG%" 2>&1
%ADB% %S% shell "md5sum /data/local/tmp/touchpadd" > "%~dp0md5_proiector.txt" 2>&1
type "%~dp0md5_proiector.txt" >> "%LOG%"
findstr /c:"7b76ca689e71cc2ec456341cc23cff3f" "%~dp0md5_proiector.txt" >nul || goto fail
%ADB% %S% remount >> "%LOG%" 2>&1
%ADB% %S% shell "pkill touchpadd; sleep 1; cp /data/local/tmp/touchpadd /system/bin/touchpadd; md5sum /system/bin/touchpadd; chmod 755 /system/bin/touchpadd; [ -f /sdcard/bk/install-recovery.sh.original ] || cp /system/bin/install-recovery.sh /sdcard/bk/install-recovery.sh.original; grep -q touchpadd /system/bin/install-recovery.sh || echo '/system/bin/touchpadd 8099 >/dev/null 2>&1 &' >> /system/bin/install-recovery.sh; tail -2 /system/bin/install-recovery.sh; sync" >> "%LOG%" 2>&1
echo 2/3 il pornesc acum...
%ADB% %S% shell "pkill touchpadd; sleep 1; /system/bin/touchpadd 8099; sleep 1; ps | grep touchpadd; netstat -ant | grep 8099" >> "%LOG%" 2>&1
timeout /t 2 /nobreak >nul
echo --- test >> "%LOG%"
curl.exe -s -m 5 http://192.168.1.92:8099/ping >> "%LOG%" 2>&1
echo. >> "%LOG%"
echo 3/3 eliberez conexiunea pentru home assistant...
%ADB% disconnect >> "%LOG%" 2>&1
%ADB% kill-server >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
exit /b 0
:fail
echo --- copiere incompleta >> "%LOG%"
%ADB% disconnect >> "%LOG%" 2>&1
%ADB% kill-server >> "%LOG%" 2>&1
echo EROARE la copiere - nu am modificat nimic.
pause
exit /b 1
