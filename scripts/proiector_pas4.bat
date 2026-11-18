@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log4.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 4 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/3 termin backup-ul...
echo --- backup rest >> "%LOG%"
for %%f in (tvconfig tvdatabase tvcustomer MBOOT tvservice) do (
  %ADB% %S% pull /sdcard/bk/%%f.img "%~dp0backup\bk\%%f.img" >> "%LOG%" 2>&1
)
dir "%~dp0backup\bk" >> "%LOG%" 2>&1
echo 2/3 pun certificatele lets encrypt...
echo --- remount >> "%LOG%"
%ADB% %S% remount >> "%LOG%" 2>&1
%ADB% %S% shell "mount | grep ' /system '" >> "%LOG%" 2>&1
%ADB% %S% push "%~dp06187b673.0" /system/etc/security/cacerts/6187b673.0 >> "%LOG%" 2>&1
%ADB% %S% push "%~dp08794b4e3.0" /system/etc/security/cacerts/8794b4e3.0 >> "%LOG%" 2>&1
%ADB% %S% shell "chmod 644 /system/etc/security/cacerts/6187b673.0 /system/etc/security/cacerts/8794b4e3.0; chown root:root /system/etc/security/cacerts/6187b673.0 /system/etc/security/cacerts/8794b4e3.0; ls -l /system/etc/security/cacerts/6187b673.0 /system/etc/security/cacerts/8794b4e3.0; sync" >> "%LOG%" 2>&1
echo 3/3 repornesc proiectorul...
%ADB% %S% reboot >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. proiectorul reporneste.
pause
