@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log24.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
echo === pas 24 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/4 copiez pozele noi...
del /q "%~dp0boot0_nou.bin" 2>nul
certutil -f -decode "%~dp0boot0_nou.b64.txt" "%~dp0boot0_nou.bin" >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0boot0_nou.bin" /data/local/tmp/boot0_nou.bin >> "%LOG%" 2>&1
%ADB% %S% push "%~dp0bootanimation_nou.zip" /data/local/tmp/bootanimation_nou.zip >> "%LOG%" 2>&1
%ADB% %S% shell "md5sum /data/local/tmp/boot0_nou.bin /data/local/tmp/bootanimation_nou.zip" > "%~dp0md5_proiector.txt" 2>&1
type "%~dp0md5_proiector.txt" >> "%LOG%"
findstr /c:"b173a51f9f80d7f0a8c80726d04b9bec" "%~dp0md5_proiector.txt" >nul || goto fail
findstr /c:"28f2bf14b64e7f98072b3e0ec50fca69" "%~dp0md5_proiector.txt" >nul || goto fail
echo 2/4 salvez pozele originale...
%ADB% %S% shell "mkdir -p /sdcard/bk; [ -f /sdcard/bk/boot0_original.jpg ] || cp /tvconfig/boot0.jpg /sdcard/bk/boot0_original.jpg; [ -f /sdcard/bk/bootanimation_original.zip ] || cp /system/media/bootanimation.zip /sdcard/bk/bootanimation_original.zip; ls -l /sdcard/bk/" >> "%LOG%" 2>&1
%ADB% %S% pull /sdcard/bk/boot0_original.jpg "%~dp0backup\boot0_original.jpg" >> "%LOG%" 2>&1
%ADB% %S% pull /sdcard/bk/bootanimation_original.zip "%~dp0backup\bootanimation_original.zip" >> "%LOG%" 2>&1
echo 3/4 pun pozele noi...
%ADB% %S% remount >> "%LOG%" 2>&1
%ADB% %S% shell "mount -o remount,rw /tvconfig; df /tvconfig; cp /data/local/tmp/boot0_nou.bin /tvconfig/boot0.jpg; chmod 644 /tvconfig/boot0.jpg; cp /data/local/tmp/bootanimation_nou.zip /system/media/bootanimation.zip; chown root:root /system/media/bootanimation.zip; chmod 644 /system/media/bootanimation.zip; sync; md5sum /tvconfig/boot0.jpg /system/media/bootanimation.zip; mount -o remount,ro /tvconfig; rm -f /data/local/tmp/boot0_nou.bin /data/local/tmp/bootanimation_nou.zip" >> "%LOG%" 2>&1
echo 4/4 repornesc ca sa vezi noua pornire...
%ADB% %S% reboot >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. urmareste pornirea proiectorului.
pause
exit /b 0
:fail
echo --- copiere incompleta, nu am modificat nimic >> "%LOG%"
echo EROARE la copiere - nu am modificat nimic.
pause
exit /b 1
