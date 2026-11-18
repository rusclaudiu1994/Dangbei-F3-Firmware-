@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log35.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 35 %date% %time% > "%LOG%"
if not exist "%~dp0token.txt" (
  echo LIPSESTE token.txt - vezi instructiunile de la claude.
  echo --- lipseste token.txt >> "%LOG%"
  pause
  exit /b 1
)
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/4 actualizez serviciul de pe proiector...
%ADB% %S% push "%~dp0touchpadd" /data/local/tmp/touchpadd >> "%LOG%" 2>&1
%ADB% %S% shell "md5sum /data/local/tmp/touchpadd" > "%~dp0md5_proiector.txt" 2>&1
type "%~dp0md5_proiector.txt" >> "%LOG%"
findstr /c:"14bc347d76e9f476c204f2117aa9853d" "%~dp0md5_proiector.txt" >nul || goto fail
%ADB% %S% remount >> "%LOG%" 2>&1
%ADB% %S% shell "pkill touchpadd; sleep 1; cp /data/local/tmp/touchpadd /system/bin/touchpadd; chmod 755 /system/bin/touchpadd; md5sum /system/bin/touchpadd; sync" >> "%LOG%" 2>&1
echo 2/4 pun tokenul home assistant (doar root il poate citi)...
%ADB% %S% shell "mkdir -p /data/touchpadd; chmod 700 /data/touchpadd" >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0token.txt" /data/touchpadd/token >nul 2>&1
%ADB% %S% shell "chown root:root /data/touchpadd/token; chmod 600 /data/touchpadd/token; ls -l /data/touchpadd/ | sed 's/token.*/token (ascuns)/'" >> "%LOG%" 2>&1
echo 3/4 instalez aplicatia Camera Levi...
%ADB% %S% install -r "%~dp0CameraLevi.apk" >> "%LOG%" 2>&1
%ADB% %S% shell "/system/bin/touchpadd 8099; sleep 1; netstat -ant | grep 8099" >> "%LOG%" 2>&1
echo --- test camera >> "%LOG%"
curl.exe -s -m 6 -o "%~dp0cam_test.bin" -w "http=%%{http_code} bytes=%%{size_download} type=%%{content_type}" http://192.168.1.92:8099/cam.mjpg >> "%LOG%" 2>&1
echo. >> "%LOG%"
echo 4/4 pornesc Camera Levi pe proiector...
%ADB% %S% shell "monkey -p ro.rus.cameralevi -c android.intent.category.LAUNCHER 1" >> "%LOG%" 2>&1
%ADB% disconnect >> "%LOG%" 2>&1
%ADB% kill-server >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
exit /b 0
:fail
echo --- copiere incompleta >> "%LOG%"
%ADB% disconnect >> "%LOG%" 2>&1
%ADB% kill-server >> "%LOG%" 2>&1
echo EROARE la copiere - nu am modificat nimic.
pause
exit /b 1
