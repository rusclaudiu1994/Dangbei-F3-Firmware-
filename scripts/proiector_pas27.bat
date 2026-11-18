@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log27.txt
set ADB="%~dp0platform-tools\adb.exe"
set S=-s 192.168.1.92:5555
set P=/dev/block/platform/mstar_mci.0/by-name/MPOOL
echo === pas 27 %date% %time% > "%LOG%"
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
%ADB% %S% root >> "%LOG%" 2>&1
timeout /t 5 /nobreak >nul
%ADB% connect 192.168.1.92:5555 >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
echo 1/4 copiez setarile corectate si verific...
%ADB% %S% push "%~dp0MPOOL_patched.img" /sdcard/bk/MPOOL_patched.img >> "%LOG%" 2>&1
%ADB% %S% shell "md5sum /sdcard/bk/MPOOL_patched.img; dd if=%P% bs=1048576 2>/dev/null | md5sum" > "%~dp0md5_proiector.txt" 2>&1
type "%~dp0md5_proiector.txt" >> "%LOG%"
findstr /c:"98c5c5d50f1841a8a90eac47ff959bc3" "%~dp0md5_proiector.txt" >nul || goto fail
findstr /c:"1aa17d13ac32f5045b6b6d1af810a738" "%~dp0md5_proiector.txt" >nul || goto fail
echo 2/4 scriu setarea (10 octeti schimbati)...
%ADB% %S% shell "dd if=/sdcard/bk/MPOOL_patched.img of=%P% bs=1048576; sync; dd if=%P% bs=1048576 2>/dev/null | md5sum" > "%~dp0md5_proiector.txt" 2>&1
type "%~dp0md5_proiector.txt" >> "%LOG%"
findstr /c:"98c5c5d50f1841a8a90eac47ff959bc3" "%~dp0md5_proiector.txt" >nul || goto restore
echo 3/4 scris corect. repornesc proiectorul...
echo --- scris corect >> "%LOG%"
%ADB% %S% reboot >> "%LOG%" 2>&1
echo 4/4 GATA. la pornire ar trebui sa apara poza ta de la inceput.
echo === gata >> "%LOG%"
pause
exit /b 0
:restore
echo --- verificare esuata dupa scriere, pun inapoi originalul >> "%LOG%"
%ADB% %S% shell "dd if=/sdcard/bk/MPOOL.img of=%P% bs=1048576; sync; dd if=%P% bs=1048576 2>/dev/null | md5sum" >> "%LOG%" 2>&1
echo ATENTIE: scrierea nu s-a verificat, am pus originalul inapoi. NU reporni, scrie-i lui claude.
pause
exit /b 1
:fail
echo --- verificare initiala esuata, nu am scris nimic >> "%LOG%"
echo EROARE - nu am modificat nimic. scrie-i lui claude.
pause
exit /b 1
