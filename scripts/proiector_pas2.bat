@echo off
setlocal
cd /d "%~dp0"
set LOG=%~dp0proiector_log2.txt
echo === pas 2 %date% %time% > "%LOG%"
echo caut proiectorul in retea, dureaza ~1 minut...
echo --- ipconfig >> "%LOG%"
ipconfig >> "%LOG%" 2>&1
echo --- ping >> "%LOG%"
ping -n 3 192.168.1.92 >> "%LOG%" 2>&1
echo --- arp >> "%LOG%"
arp -a >> "%LOG%" 2>&1
echo --- scan 5555 >> "%LOG%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ips = Get-NetIPAddress -AddressFamily IPv4 | ?{ $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' }; foreach($a in $ips){ $p=$a.IPAddress.Split('.'); $net=$p[0]+'.'+$p[1]+'.'+$p[2]; 'retea '+$net; $tasks=@{}; 1..254 | %%{ $ip=$net+'.'+$_; $c=New-Object Net.Sockets.TcpClient; $tasks[$ip]=@($c,$c.ConnectAsync($ip,5555)) }; Start-Sleep -Milliseconds 2500; foreach($k in $tasks.Keys){ $t=$tasks[$k]; if($t[1].IsCompleted -and -not $t[1].IsFaulted -and $t[0].Connected){ 'ADB DESCHIS: '+$k }; $t[0].Close() } }" >> "%LOG%" 2>&1
set ADB="%~dp0platform-tools\adb.exe"
for /f "tokens=3" %%a in ('findstr /c:"ADB DESCHIS" "%LOG%"') do (
  echo --- conectare %%a >> "%LOG%"
  %ADB% connect %%a:5555 >> "%LOG%" 2>&1
)
echo.
echo daca pe proiector apare "allow usb debugging?" bifeaza "always allow" si ok
timeout /t 25 /nobreak
%ADB% devices -l >> "%LOG%" 2>&1
echo === gata >> "%LOG%"
echo GATA. poti inchide fereastra.
pause
