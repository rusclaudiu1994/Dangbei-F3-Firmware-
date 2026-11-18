@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log14.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 14 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/4 instalez webview nou (bromite 106), ~100 mb, dureaza 1-3 minute...
echo --- install >> "%LOG%"
%ADB% %S% install -r "%~dp0BromiteWebView_106.apk" >> "%LOG%" 2>&1
%ADB% %S% shell "dumpsys package org.bromite.webview | grep -E 'versionName|nativeLibraryDir'" >> "%LOG%" 2>&1
echo 2/4 verific fisierul de configurare...
%ADB% %S% remount >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0WebViewOverlay.apk" /data/local/tmp/WebViewOverlay.apk >> "%LOG%" 2>&1
echo --- test idmap >> "%LOG%"
%ADB% %S% shell "rm -f /data/local/tmp/t.idmap; idmap --path /system/framework/framework-res.apk /data/local/tmp/WebViewOverlay.apk /data/local/tmp/t.idmap; echo idmap_rc=$?; ls -l /data/local/tmp/t.idmap" >> "%LOG%" 2>&1
findstr /c:"idmap_rc=0" "%LOG%" >nul
if errorlevel 1 (
  echo EROARE: configurarea nu e acceptata de sistem, ma opresc fara sa modific nimic. >> "%LOG%"
  echo EROARE - nu am modificat nimic. scrie-i lui claude "gata".
  pause
  exit /b 1
)
echo 3/4 activez webview-ul nou...
echo --- overlay >> "%LOG%"
%ADB% %S% shell "ls -ld /vendor; mkdir -p /system/vendor/overlay; chmod 755 /system/vendor/overlay; cp /data/local/tmp/WebViewOverlay.apk /system/vendor/overlay/WebViewOverlay.apk; chmod 644 /system/vendor/overlay/WebViewOverlay.apk; ls -l /vendor/overlay/; ls -l /data/resource-cache/; rm -f /data/resource-cache/overlays.list; sync" >> "%LOG%" 2>&1
echo 4/4 repornesc si astept pornirea (max 6 minute)...
%ADB% %S% reboot >> "%LOG%" 2>&1
timeout /t 60 /nobreak >nul
set /a N=0
:retry
set /a N+=1
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if "%BC%"=="1" goto booted
if %N% GEQ 60 goto failed
timeout /t 5 /nobreak >nul
goto retry
:failed
echo --- NU a pornit in 6 minute, anulez modificarea >> "%LOG%"
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% remount >> "%LOG%" 2>&1
%ADB% %S% shell "rm -f /system/vendor/overlay/WebViewOverlay.apk /data/resource-cache/overlays.list; sync; reboot" >> "%LOG%" 2>&1
echo proiectorul nu a pornit normal - am incercat anularea. scrie-i lui claude.
pause
exit /b 1
:booted
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo --- dupa pornire >> "%LOG%"
%ADB% %S% shell "cat /data/resource-cache/overlays.list; ls -l /data/resource-cache/; am start -a android.intent.action.VIEW -d https://www.whatsmybrowser.org -n com.android.htmlviewer/.HTMLViewerActivity >/dev/null 2>&1; sleep 8; logcat -d -v time | grep -iE 'WebViewFactory|webviewchromium|bromite|WebViewUpdate|chromium.*version' | tail -25" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
