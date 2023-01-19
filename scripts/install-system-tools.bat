
ECHO Installing SDelete ...
if not exist "C:\Windows\System32\SDelete.exe" (
  if not exist "C:\Windows\Temp\SDelete.zip" (
	powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SDelete.zip', 'C:\Windows\Temp\SDelete.zip')" <NUL
  )
  powershell -Command "Expand-Archive 'C:\Windows\Temp\SDelete.zip' 'C:\Windows\System32' -Force"
  del "C:\Windows\Temp\SDelete.zip"
  del "C:\Windows\System32\SDelete64a.exe"
)
cmd /c %SystemRoot%\System32\reg.exe ADD HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f

ECHO Installing AutoLogon ...
if not exist "C:\Windows\System32\AutoLogon.exe" (
  if not exist "C:\Windows\Temp\AutoLogon.zip" (
	powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/AutoLogon.zip', 'C:\Windows\Temp\AutoLogon.zip')" <NUL
  )
  powershell -Command "Expand-Archive 'C:\Windows\Temp\AutoLogon.zip' 'C:\Windows\System32' -Force"
  del "C:\Windows\Temp\AutoLogon.zip"
  del "C:\Windows\System32\AutoLogon64a.exe"
)
cmd /c %SystemRoot%\System32\reg.exe ADD HKCU\Software\Sysinternals\AutoLogon /v EulaAccepted /t REG_DWORD /d 1 /f

ECHO Installing Bind (Dig) ...
if not exist "C:\Program Files\Bind" ( md "C:\Program Files\Bind" )
if not exist "C:\Program Files\Bind\dig.exe" (
  if not exist "C:\Windows\Temp\BIND9.zip" (
	powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://downloads.isc.org/isc/bind9/9.16.31/BIND9.16.31.x64.zip', 'C:\Windows\Temp\BIND9.zip')" <NUL
  )
  powershell -Command "Expand-Archive 'C:\Windows\Temp\BIND9.zip' 'C:\Program Files\Bind' -Force"
  del "C:\Windows\Temp\BIND9.zip"
)
