@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log10.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 10 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/4 salvez build.prop si scot limita de 120 secunde la compilare...
%ADB% %S% pull /system/build.prop "%~dp0backup\build.prop.original" >> "%LOG%" 2>&1
%ADB% %S% remount >> "%LOG%" 2>&1
echo --- build.prop >> "%LOG%"
%ADB% %S% shell "grep -q 'dex2oat-flags' /system/build.prop || echo 'dalvik.vm.dex2oat-flags=--no-watch-dog' >> /system/build.prop; grep dex2oat /system/build.prop; setprop dalvik.vm.dex2oat-flags --no-watch-dog; getprop dalvik.vm.dex2oat-flags; sync" >> "%LOG%" 2>&1
echo 2/4 compilez google play services, poate dura 5-15 minute, nu inchide...
echo --- gms compile >> "%LOG%"
%ADB% %S% logcat -c
%ADB% %S% shell pm force-dex-opt com.google.android.gms >> "%LOG%" 2>&1
%ADB% %S% shell "logcat -d -v time | grep -E 'F/dex2oat|dex2oat took|E/installd' | tail -10; ls -l /data/app/com.google.android.gms-1/oat/*" >> "%LOG%" 2>&1
echo 3/4 sterg wps...
echo --- wps >> "%LOG%"
%ADB% %S% shell "pm path cn.wps.moffice_i18n_TV; ls -ld /data/app/cn.wps*; rm -rf /data/app/cn.wps.moffice_i18n_TV-*; rm -rf /data/data/cn.wps.moffice_i18n_TV; rm -f /data/dalvik-cache/*/data@app@cn.wps*; echo dupa:; ls -ld /data/app/cn.wps* 2>&1; sync" >> "%LOG%" 2>&1
echo 4/4 repornesc proiectorul...
%ADB% %S% reboot >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. proiectorul reporneste - urmareste daca mai apare optimizarea.
pause
