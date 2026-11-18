@echo off
cd /d "%~dp0"
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
%ADB% connect 192.168.1.92:5555
%ADB% %S% root
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555
%ADB% %S% remount
%ADB% %S% shell "mount -o remount,rw /tvconfig; cp /sdcard/bk/boot0_original.jpg /tvconfig/boot0.jpg; cp /sdcard/bk/bootanimation_original.zip /system/media/bootanimation.zip; chmod 644 /tvconfig/boot0.jpg /system/media/bootanimation.zip; sync; mount -o remount,ro /tvconfig; reboot"
echo gata - pozele originale sunt puse inapoi.
pause
