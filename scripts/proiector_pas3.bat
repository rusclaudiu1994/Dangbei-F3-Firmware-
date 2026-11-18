@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log3.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 3 %date% %time% > "%LOG%"
echo citesc informatii si fac backup la partitiile de calibrare...
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
echo --- root >> "%LOG%"
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
%ADB% devices -l >> "%LOG%" 2>&1
echo --- id >> "%LOG%"
%ADB% %S% shell id >> "%LOG%" 2>&1
echo --- uname >> "%LOG%"
%ADB% %S% shell uname -a >> "%LOG%" 2>&1
echo --- props >> "%LOG%"
%ADB% %S% shell "getprop ro.build.display.id; getprop ro.build.type; getprop ro.product.rom.romvername; getprop ro.product.model_number; getprop persist.sys.locale; getprop ro.product.cpu.abi" >> "%LOG%" 2>&1
echo --- disabled pkgs >> "%LOG%"
%ADB% %S% shell pm list packages -d >> "%LOG%" 2>&1
echo --- all pkgs >> "%LOG%"
%ADB% %S% shell pm list packages -f >> "%LOG%" 2>&1
echo --- versions >> "%LOG%"
for %%p in (com.android.vending com.google.android.gms com.google.android.gsf com.android.webview com.android.chrome com.dangbei.tvlauncher com.google.android.youtube.tv) do (
  echo [%%p] >> "%LOG%"
  %ADB% %S% shell "dumpsys package %%p | grep -E 'versionName|enabled=|codePath'" >> "%LOG%" 2>&1
)
echo --- storage >> "%LOG%"
%ADB% %S% shell df >> "%LOG%" 2>&1
echo --- cert >> "%LOG%"
%ADB% %S% shell "ls /system/etc/security/cacerts | grep -c ." >> "%LOG%" 2>&1
%ADB% %S% shell "ls /system/etc/security/cacerts/6187b673.0" >> "%LOG%" 2>&1
echo --- by-name >> "%LOG%"
%ADB% %S% shell "ls -l /dev/block/platform/*/by-name/" >> "%LOG%" 2>&1
echo --- backup >> "%LOG%"
%ADB% %S% shell "mkdir -p /sdcard/bk; cd /dev/block/platform/*/by-name/ && for p in misc recovery boot tee RTPM dtb frc tvservice tvconfig tvdatabase tvcustomer MBOOT mboot; do [ -e $p ] && dd if=$p of=/sdcard/bk/$p.img bs=1048576 2>&1 | tail -1; done; ls -l /sdcard/bk" >> "%LOG%" 2>&1
if not exist "%~dp0backup" mkdir "%~dp0backup"
%ADB% %S% pull /sdcard/bk "%~dp0backup" >> "%LOG%" 2>&1
dir "%~dp0backup" /s >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
