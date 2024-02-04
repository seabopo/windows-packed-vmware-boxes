
if not exist "C:\Windows\Temp\SDelete.exe" (
  if not exist "C:\Windows\Temp\SDelete.zip" (
	powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SDelete.zip', 'C:\Windows\Temp\SDelete.zip')" <NUL
  )
  powershell -Command "Expand-Archive 'C:\Windows\Temp\SDelete.zip' 'C:\Windows\Temp'"
)

net stop wuauserv
rmdir /S /Q C:\Windows\SoftwareDistribution\Download
mkdir C:\Windows\SoftwareDistribution\Download
net start wuauserv

cmd /c %SystemRoot%\System32\reg.exe ADD HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
cmd /c C:\Windows\Temp\sdelete.exe -q -z C:
