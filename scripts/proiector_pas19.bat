@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log19.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 19 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/3 copiez webview-ul corectat (~100 mb, ~3 minute)...
%ADB% %S% push "%~dp0webview_bromite_sys2.apk" /data/local/tmp/webview2.apk >> "%LOG%" 2>&1
%ADB% %S% shell "md5sum /data/local/tmp/webview2.apk" > "%~dp0md5_proiector.txt" 2>&1
type "%~dp0md5_proiector.txt" >> "%LOG%"
findstr /c:"73999ea16b9d58255c8fe9c5cd25e93c" "%~dp0md5_proiector.txt" >nul || goto pushfail
echo 2/3 il inlocuiesc si repornesc...
%ADB% %S% remount >> "%LOG%" 2>&1
%ADB% %S% shell "cp /data/local/tmp/webview2.apk /system/app/webview/webview.apk; chown root:root /system/app/webview/webview.apk; chmod 644 /system/app/webview/webview.apk; rm -f /data/dalvik-cache/*/system@app@webview@webview.apk@classes.dex /data/local/tmp/webview2.apk; sync; md5sum /system/app/webview/webview.apk" >> "%LOG%" 2>&1
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
echo --- copiere incompleta, nu am modificat nimic >> "%LOG%"
echo EROARE la copiere - nu am modificat nimic. scrie-i lui claude.
pause
exit /b 1
:booted
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 3/3 verific...
echo --- dupa pornire >> "%LOG%"
%ADB% %S% logcat -c
%ADB% %S% shell "am start -a android.intent.action.VIEW -d file:///system/etc/hosts -t text/html -n com.android.htmlviewer/.HTMLViewerActivity; sleep 12; dumpsys activity activities | grep mFocusedActivity; logcat -d -v time | grep -iE 'WebViewFactory|AndroidRuntime|Caused by|chromium' | head -25; input keyevent 4" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
