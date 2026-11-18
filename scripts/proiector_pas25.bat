@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log25.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 25 %date% %time% > "%LOG%"
:retry
%ADB% connect 192.168.1.92:5555 >nul 2>&1
set BC=
for /f %%b in ('%ADB% %S% shell getprop sys.boot_completed 2^>nul') do set BC=%%b
if not "%BC%"=="1" ( timeout /t 5 /nobreak >nul & goto retry )
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo verific de ce prima poza nu s-a schimbat (doar citesc)...
%ADB% %S% shell "grep tvconfig /proc/mounts; md5sum /tvconfig/boot0.jpg; ls -li /tvconfig/; dd if=/dev/block/platform/mstar_mci.0/by-name/tvconfig of=/sdcard/bk/tvconfig_acum.img bs=1048576 2>&1 | tail -1; getprop | grep -iE 'bootvideo|bootlogo|logo'" >> "%LOG%" 2>&1
%ADB% %S% pull /sdcard/bk/tvconfig_acum.img "%~dp0backup\tvconfig_acum.img" >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
