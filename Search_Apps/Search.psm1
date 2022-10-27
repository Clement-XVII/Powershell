function boucle {
    foreach ($application in $Software) {

            if ($application -match $Name) {
                $DName = $Application.DisplayName
                $Uninstall = $Application.UnInstallString
                $NameOrganisation = $Application.Publisher
                $Version = $Application.DisplayVersion
                $Date = $Application.InstallDate
                Write-Host -ForegroundColor Green "Application name: " -NoNewline
                Write-Host -ForegroundColor White "$DName"
                Write-Host -ForegroundColor Green "Version: " -NoNewline
                Write-Host -ForegroundColor White "$Version"
                Write-Host -ForegroundColor Green "Installation date: " -NoNewline
                Write-Host -ForegroundColor White "$Date"
                Write-Host -ForegroundColor Green "Uninstall string: " -NoNewline
                Write-Host -ForegroundColor White "$Uninstall"
                Write-Host -ForegroundColor Green "Organization name: " -NoNewline
                Write-Host -ForegroundColor White "$NameOrganisation`n"
                $i = $i + 1
            }
        }
        if ($i -eq 0) {
            Write-Host "$Name has not been found or is not installed !`n" -ForegroundColor Red
        }
}

function search {
   
    [CmdletBinding()]
    Param([Parameter(Mandatory=$false)]
    [string]$Name = '')
    $Software = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | select DisplayName, UninstallString, Publisher, DisplayVersion, InstallDate
    $i = 0
    
    if ($PSBoundParameters.Keys.Contains("Name"))
    {
        boucle
    }
    else {
        $Name = Read-Host -Prompt "Enter the application name"
        if (-not($Name)) {
            Write-Host "Please enter the application name " -ForegroundColor Red
            Write-Host "All applications :`n " -ForegroundColor Green
            sleep 1
        }
        elseif ($Name) {
            Write-Host "The results for $Name are:`n" -ForegroundColor Green
        }
        boucle
    }
}
