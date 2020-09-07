# Delete and stop the service if it already exists.
if (Get-Service auditbeat -ErrorAction SilentlyContinue) {
  $service = Get-WmiObject -Class Win32_Service -Filter "name='auditbeat'"
  $service.StopService()
  Start-Sleep -s 1
  $service.delete()
}

$workdir = Split-Path $MyInvocation.MyCommand.Path

# Create the new service.
New-Service -name auditbeat `
  -displayName Auditbeat `
  -binaryPathName "`"$workdir\auditbeat.exe`" -environment=windows_service -c `"$workdir\auditbeat.yml`" -path.home `"$workdir`" -path.data `"C:\ProgramData\auditbeat`" -path.logs `"C:\ProgramData\auditbeat\logs`" -E logging.files.redirect_stderr=true"

# Attempt to set the service to delayed start using sc config.
Try {
  Start-Process -FilePath sc.exe -ArgumentList 'config auditbeat start= delayed-auto'
}
Catch { Write-Host -f red "An error occured setting the service to delayed start." }
