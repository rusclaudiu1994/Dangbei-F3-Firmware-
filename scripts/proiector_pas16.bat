@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log16.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 16 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
echo repornesc proiectorul o data (webview-ul nou se activeaza la a doua pornire)...
%ADB% %S% reboot >> "%LOG%" 2>&1
timeout /t 60 /nobreak >nul
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo verific webview-ul...
%ADB% %S% shell "ls -l /data/resource-cache/; cat /data/resource-cache/overlays.list; am start -a android.intent.action.VIEW -d file:///system/etc/hosts -t text/html -n com.android.htmlviewer/.HTMLViewerActivity; sleep 8; input keyevent 4; logcat -d -v time | grep -iE 'WebViewFactory|idmap|overlay|bromite' | tail -25" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
