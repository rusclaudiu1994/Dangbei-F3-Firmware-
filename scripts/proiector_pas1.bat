@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log.txt
echo === pas 1 %date% %time% > "%LOG%"
if not exist "%~dp0platform-tools\adb.exe" (
  echo descarc adb... 
  curl.exe -L -o "%~dp0pt.zip" https://dl.google.com/android/repository/platform-tools-latest-windows.zip >> "%LOG%" 2>&1
  tar.exe -xf "%~dp0pt.zip" -C "%~dp0" >> "%LOG%" 2>&1
  if not exist "%~dp0platform-tools\adb.exe" powershell -NoProfile -Command "Expand-Archive -Force '%~dp0pt.zip' '%~dp0'" >> "%LOG%" 2>&1
)
set ADB="%~dp0platform-tools\adb.exe"
if not exist %ADB% ( echo EROARE: adb nu s-a descarcat >> "%LOG%" & echo adb nu s-a descarcat & pause & exit /b 1 )
echo.
echo ==================================================
echo  daca pe proiector apare "allow usb debugging?"
echo  bifeaza "always allow" si apasa ok cu telecomanda
echo ==================================================
echo.
%ADB% start-server >> "%LOG%" 2>&1
for /l %%i in (1,1,6) do (
  %ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
  timeout /t 5 /nobreak >nul
)
echo --- devices >> "%LOG%"
%ADB% devices -l >> "%LOG%" 2>&1
echo --- root >> "%LOG%"
%ADB% -s 192.168.1.92:5555 root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
set S=-s 192.168.1.92:5555
echo --- id >> "%LOG%"
%ADB% %S% shell id >> "%LOG%" 2>&1
echo --- uname >> "%LOG%"
%ADB% %S% shell uname -a >> "%LOG%" 2>&1
echo --- props >> "%LOG%"
%ADB% %S% shell getprop ro.build.display.id >> "%LOG%" 2>&1
%ADB% %S% shell getprop ro.build.type >> "%LOG%" 2>&1
%ADB% %S% shell getprop ro.product.rom.romvername >> "%LOG%" 2>&1
%ADB% %S% shell getprop ro.product.model_number >> "%LOG%" 2>&1
%ADB% %S% shell getprop persist.sys.locale >> "%LOG%" 2>&1
echo --- google pkgs >> "%LOG%"
%ADB% %S% shell pm list packages -f -d >> "%LOG%" 2>&1
echo --- all pkgs >> "%LOG%"
%ADB% %S% shell pm list packages -f >> "%LOG%" 2>&1
echo --- versions >> "%LOG%"
%ADB% %S% shell dumpsys package com.android.vending ^| grep -E "versionName^|enabled" >> "%LOG%" 2>&1
%ADB% %S% shell dumpsys package com.google.android.gms ^| grep -E "versionName^|enabled" >> "%LOG%" 2>&1
%ADB% %S% shell dumpsys package com.android.webview ^| grep -E "versionName" >> "%LOG%" 2>&1
%ADB% %S% shell dumpsys package com.dangbei.tvlauncher ^| grep -E "versionName" >> "%LOG%" 2>&1
echo --- storage >> "%LOG%"
%ADB% %S% shell df >> "%LOG%" 2>&1
%ADB% %S% shell ls /system/etc/security/cacerts ^| grep 6187 >> "%LOG%" 2>&1
echo --- by-name >> "%LOG%"
%ADB% %S% shell ls -l /dev/block/platform/*/by-name/ >> "%LOG%" 2>&1
%ADB% %S% shell ls -l /dev/block/by-name/ >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo.
echo GATA. poti inchide fereastra.
pause
