@echo off
cd /d "%~dp0"
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
%ADB% connect 192.168.1.92:5555
%ADB% %S% root
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555
%ADB% %S% remount
%ADB% %S% shell "rm -f /system/vendor/overlay/WebViewOverlay.apk /data/resource-cache/overlays.list; sync; reboot"
echo anulat - proiectorul reporneste cu webview-ul vechi.
pause
