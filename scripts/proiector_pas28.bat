@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log28.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 28 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
echo testez mouse-ul dangbei (nu atinge telecomanda ~30 secunde)...
%ADB% %S% shell "input keyevent 3; sleep 2; am startservice -a intent.action.START_MOUSE -n com.dangs.mouse/.service.FloatService; sleep 3; screencap -p /sdcard/m1.png; input keyevent 22 22 22 22 22 22; sleep 2; screencap -p /sdcard/m2.png; input keyevent 20 20 20 20; sleep 2; screencap -p /sdcard/m3.png; dumpsys window windows | grep -iE 'mCurrentFocus|dangs'" >> "%LOG%" 2>&1
%ADB% %S% pull /sdcard/m1.png "%~dp0m1.png" >> "%LOG%" 2>&1
%ADB% %S% pull /sdcard/m2.png "%~dp0m2.png" >> "%LOG%" 2>&1
%ADB% %S% pull /sdcard/m3.png "%~dp0m3.png" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
