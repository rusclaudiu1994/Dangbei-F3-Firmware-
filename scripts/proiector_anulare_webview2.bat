@echo off
cd /d "%~dp0"
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo revin la webview-ul original...
%ADB% connect 192.168.1.92:5555
%ADB% %S% root
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555
%ADB% %S% remount
%ADB% %S% shell "ls -l /sdcard/bk/webview_original.apk" | findstr webview_original >nul
if errorlevel 1 %ADB% %S% push "%~dp0backup\webview_original.apk" /sdcard/bk/webview_original.apk
%ADB% %S% shell "W=/system/app/webview; rm -rf $W/lib; cp /sdcard/bk/webview_original.apk $W/webview.apk; chown root:root $W/webview.apk; chmod 644 $W/webview.apk; rm -f /data/dalvik-cache/*/system@app@webview@webview.apk@classes.dex; sync; reboot"
echo gata - proiectorul reporneste cu webview-ul original.
pause
