@echo off
cd /d "%~dp0"
"%~dp0platform-tools\adb.exe" disconnect
"%~dp0platform-tools\adb.exe" kill-server
echo GATA - tableta s-a deconectat de la proiector. scrie-i lui claude "gata".
pause
