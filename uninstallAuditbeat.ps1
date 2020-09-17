Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser	
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

$ServiceName = "auditbeat"

if($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Set-ExecutionPolicy Unrestricted

    #Change Directory to Auditbeat
    $currentLocation = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

    If ( -Not (Test-Path -Path "$currentLocation\auditbeat") )
    {
        Write-Host -Object "Path $currentLocation\auditbeat does not exit, exiting..." -ForegroundColor Red
        Exit 1
    }
    Else
    {
        Set-Location -Path "$currentLocation\auditbeat"
    }


    #Stops auditbeat from running
    Stop-Service -Force $ServiceName

    #Get The auditbeat Status
    Get-Service $ServiceName
    C:\Windows\System32\sc.exe delete $ServiceName

    #Change Directory to auditbeat5
    Set-Location -Path 'c:\'

    "`nUninstalling Auditbeat Now..."

    Get-ChildItem -Path $currentLocation -Recurse -force |
        Where-Object { -not ($_.pscontainer)} |
            Remove-Item -Force -Recurse

    Remove-Item -Recurse -Force $currentLocation

    "`nAuditbeat Uninstall Successful."

    #Close Powershell window
    #Stop-Process -Id $PID
}
else {
    Start-Process -FilePath "powershell" -ArgumentList "$('-File ""')$(Get-Location)$('\')$($MyInvocation.MyCommand.Name)$('""')" -Verb runAs
}