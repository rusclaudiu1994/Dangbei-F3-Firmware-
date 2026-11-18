@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log15.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 15 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo verific magazin play si incerc sa-l deschid pe proiector...
echo --- vending >> "%LOG%"
%ADB% %S% shell "dumpsys package com.android.vending | grep -E 'versionName|enabled|hidden|codePath'; dumpsys package com.android.vending | grep -B2 -A6 'android.intent.action.MAIN' | head -60" >> "%LOG%" 2>&1
echo --- launcher filtre >> "%LOG%"
%ADB% %S% shell "dumpsys package com.dangbei.tvlauncher | grep -iE 'hide|filter|blacklist' | head; ls /data/data/com.dangbei.tvlauncher/shared_prefs/" >> "%LOG%" 2>&1
echo --- start leanback >> "%LOG%"
%ADB% %S% logcat -c
%ADB% %S% shell "am start -a android.intent.action.MAIN -c android.intent.category.LEANBACK_LAUNCHER -p com.android.vending" >> "%LOG%" 2>&1
timeout /t 8 /nobreak >nul
%ADB% %S% shell "dumpsys activity activities | grep -E 'mFocusedActivity|mResumedActivity' ; logcat -d -v time | grep -iE 'vending|finsky|ActivityManager: (START|Displayed)|FATAL|AndroidRuntime' | tail -25" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. uita-te daca s-a deschis magazinul play pe proiector.
pause
