@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log9.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 9 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/3 sterg wps direct din sistem...
echo --- rm wps >> "%LOG%"
%ADB% %S% shell "pkill -f 'pm uninstall'; rm -rf /data/app/cn.wps.moffice_i18n_TV-* /data/data/cn.wps.moffice_i18n_TV /data/dalvik-cache/*/data@app@cn.wps*; ls /data/app; sync" >> "%LOG%" 2>&1
echo 2/3 repornesc proiectorul si astept sa porneasca...
%ADB% %S% reboot >> "%LOG%" 2>&1
timeout /t 40 /nobreak >nul
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo --- verificare wps >> "%LOG%"
%ADB% %S% shell "pm list packages | grep -i wps; echo rezultat=$?" >> "%LOG%" 2>&1
echo 3/3 test play services, poate dura 5-10 minute...
echo --- gms compile >> "%LOG%"
%ADB% %S% logcat -c
%ADB% %S% shell "nohup logcat -v time -f /data/local/tmp/dex.log >/dev/null 2>&1 &"
%ADB% %S% shell pm force-dex-opt com.google.android.gms >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
%ADB% %S% shell "grep -iE ' [EF]/|fatal|abort|signal|killed|lowmemory|swap|dex2oat took|returned|failed' /data/local/tmp/dex.log | grep -v 'Verification of' | tail -60" >> "%LOG%" 2>&1
echo --- ultimele linii dex2oat >> "%LOG%"
%ADB% %S% shell "grep -i dex2oat /data/local/tmp/dex.log | tail -15; pkill logcat; ls -l /data/app/com.google.android.gms-1/oat/*" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
