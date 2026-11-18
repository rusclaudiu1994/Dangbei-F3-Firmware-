@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log18.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 18 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/5 salvez webview-ul original (backup)...
%ADB% %S% remount >> "%LOG%" 2>&1
echo --- backup >> "%LOG%"
%ADB% %S% shell "df /system; mkdir -p /sdcard/bk; [ -f /sdcard/bk/webview_original.apk ] || cp /system/app/webview/webview.apk /sdcard/bk/webview_original.apk; ls -l /sdcard/bk/webview_original.apk" >> "%LOG%" 2>&1
if not exist "%~dp0backup\webview_original.apk" %ADB% %S% pull /sdcard/bk/webview_original.apk "%~dp0backup\webview_original.apk" >> "%LOG%" 2>&1
echo 2/5 copiez webview-ul nou pe proiector (~300 mb, 5-10 minute)...
echo --- push >> "%LOG%"
%ADB% %S% shell "mkdir -p /data/local/tmp/wv" >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0webview_bromite_sys.apk" /data/local/tmp/wv/webview.apk >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0libwebviewchromium_arm64.so" /data/local/tmp/wv/libwebviewchromium_arm64.so >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0libwebviewchromium_arm.so" /data/local/tmp/wv/libwebviewchromium_arm.so >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0libcrashpad_arm64.so" /data/local/tmp/wv/libcrashpad_arm64.so >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0libcrashpad_arm.so" /data/local/tmp/wv/libcrashpad_arm.so >> "%LOG%" 2>&1
%ADB% %S% shell "ls -l /data/local/tmp/wv" >> "%LOG%" 2>&1
echo --- md5 >> "%LOG%"
%ADB% %S% shell "cd /data/local/tmp/wv; md5sum webview.apk libwebviewchromium_arm64.so libwebviewchromium_arm.so libcrashpad_arm64.so libcrashpad_arm.so" > "%~dp0md5_proiector.txt" 2>&1
type "%~dp0md5_proiector.txt" >> "%LOG%"
findstr /c:"7d10fdcbdac9456c7ab81886b3b099a6" "%~dp0md5_proiector.txt" >nul || goto pushfail
findstr /c:"5a4858012aaf6583becfc7665e743922" "%~dp0md5_proiector.txt" >nul || goto pushfail
findstr /c:"949cf71862d3b1c03f4422f263e83d69" "%~dp0md5_proiector.txt" >nul || goto pushfail
findstr /c:"870cf145de55153ada2f59cf7c09ae01" "%~dp0md5_proiector.txt" >nul || goto pushfail
findstr /c:"56356edca830ad62edb6f27aca34b9c5" "%~dp0md5_proiector.txt" >nul || goto pushfail
echo 3/5 inlocuiesc webview-ul...
echo --- inlocuire >> "%LOG%"
%ADB% %S% uninstall org.bromite.webview >> "%LOG%" 2>&1
%ADB% %S% shell "rm -f /system/vendor/overlay/WebViewOverlay.apk /data/resource-cache/overlays.list /data/resource-cache/vendor@overlay@WebViewOverlay.apk@idmap; W=/system/app/webview; rm -f $W/webview.apk; rm -rf $W/lib; mkdir -p $W/lib/arm64 $W/lib/arm; cp /data/local/tmp/wv/webview.apk $W/webview.apk; cp /data/local/tmp/wv/libwebviewchromium_arm64.so $W/lib/arm64/libwebviewchromium.so; cp /data/local/tmp/wv/libcrashpad_arm64.so $W/lib/arm64/libcrashpad_handler_trampoline.so; cp /data/local/tmp/wv/libwebviewchromium_arm.so $W/lib/arm/libwebviewchromium.so; cp /data/local/tmp/wv/libcrashpad_arm.so $W/lib/arm/libcrashpad_handler_trampoline.so; chown -R root:root $W; chmod 755 $W $W/lib $W/lib/arm64 $W/lib/arm; chmod 644 $W/webview.apk $W/lib/arm64/* $W/lib/arm/*; rm -f /data/dalvik-cache/*/system@app@webview@webview.apk@classes.dex; sync; ls -lR $W; df /system" >> "%LOG%" 2>&1
echo 4/5 repornesc si astept pornirea (prima data poate dura ~5 minute)...
%ADB% %S% reboot >> "%LOG%" 2>&1
timeout /t 60 /nobreak >nul
set /a N=0
:retry
set /a N+=1
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if "%BC%"=="1" goto booted
if %N% GEQ 90 goto failed
timeout /t 5 /nobreak >nul
goto retry
:failed
echo --- NU a pornit, revin la webview-ul vechi >> "%LOG%"
call "%~dp0proiector_anulare_webview2.bat"
exit /b 1
:pushfail
echo --- copierea a esuat, nu am modificat sistemul >> "%LOG%"
echo EROARE la copiere - nu am modificat nimic. scrie-i lui claude.
pause
exit /b 1
:booted
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 5/5 verific...
echo --- dupa pornire >> "%LOG%"
%ADB% %S% shell "dumpsys package com.android.webview | grep -E 'versionName|primaryCpuAbi|nativeLibraryDir|codePath'; am start -a android.intent.action.VIEW -d file:///system/etc/hosts -t text/html -n com.android.htmlviewer/.HTMLViewerActivity; sleep 10; input keyevent 4; logcat -d -v time | grep -iE 'WebViewFactory|webview.*(fail|error)|chromium.*version|webview' | tail -20; rm -rf /data/local/tmp/wv" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
