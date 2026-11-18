@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log23.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 23 %date% %time% > "%LOG%"
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo caut de unde vin cardurile si golesc cache-ul launcher-ului...
echo --- launcher data >> "%LOG%"
%ADB% %S% shell "cd /data/data/com.dangbei.tvlauncher && du -s * ; ls -l databases files 2>&1 | head -40" >> "%LOG%" 2>&1
echo --- notificari recomandari >> "%LOG%"
%ADB% %S% shell "dumpsys notification | grep -iE 'pkg=|recommendation|category=' | head -30" >> "%LOG%" 2>&1
echo --- cauta tops >> "%LOG%"
%ADB% %S% shell "grep -rl -i 'Halter tops' /data/data/com.dangbei.tvlauncher /data/data/com.android.providers.tv /data/data/com.dangbei.lerad.etna.sample 2>/dev/null | head" >> "%LOG%" 2>&1
echo --- golire cache >> "%LOG%"
%ADB% %S% shell "rm -rf /data/data/com.dangbei.tvlauncher/cache/* /data/data/com.dangbei.tvlauncher/app_webview/Cache 2>/dev/null; am force-stop com.dangbei.tvlauncher; input keyevent 3; echo ok" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. uita-te pe ecranul principal daca au disparut cardurile.
pause
