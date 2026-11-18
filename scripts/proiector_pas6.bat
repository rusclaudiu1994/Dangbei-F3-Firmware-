@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log6.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 6 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/2 dezinstalez aptoide, hik-connect si wps...
echo --- uninstall >> "%LOG%"
for %%p in (cm.aptoide.pt com.hikvision.hikconnect cn.wps.moffice_i18n_TV) do (
  echo [%%p] >> "%LOG%"
  %ADB% %S% uninstall %%p >> "%LOG%" 2>&1
)
echo 2/2 testez compilarea google play services, dureaza cateva minute...
echo --- gms >> "%LOG%"
%ADB% %S% shell "ls -la /data/app/com.google.android.gms-1 /data/app/com.google.android.gms-1/*; cat /proc/meminfo | head -3; df /data" >> "%LOG%" 2>&1
%ADB% %S% logcat -c
%ADB% %S% shell pm force-dex-opt com.google.android.gms >> "%LOG%" 2>&1
%ADB% %S% shell "logcat -d -v time | grep -iE 'dex2oat|installd|DexOpt|PackageManager|art .*(fail|error)|lowmemory|killed' | head -80" >> "%LOG%" 2>&1
%ADB% %S% shell "ls -l /data/app/com.google.android.gms-1/oat/* 2>&1" >> "%LOG%" 2>&1
echo --- ramase >> "%LOG%"
%ADB% %S% shell "ls -l /data/app" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
