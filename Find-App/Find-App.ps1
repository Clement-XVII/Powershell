function Find-App {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppName
    )

    function Search-SystemExecutable {
        param([string]$exeName)

        $systemPaths = @(
            "$env:SystemRoot\System32",
            "$env:SystemRoot\SysWOW64",
            "$env:SystemRoot",
            "$env:ProgramFiles",
            "$env:ProgramFiles(x86)"
        )

        foreach ($path in $systemPaths) {
            $fullPath = Join-Path $path $exeName
            if (Test-Path $fullPath) {
                Write-Host "`n✅ Exécutable système trouvé : $fullPath" -ForegroundColor Green
            }
        }
    }

    function Search-Shortcuts {
        param([string]$appName)

        $shortcutFolders = @(
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        )

        foreach ($folder in $shortcutFolders) {
            if (Test-Path $folder) {
                $shortcuts = Get-ChildItem -Path $folder -Recurse -Filter *.lnk -ErrorAction SilentlyContinue
                foreach ($shortcut in $shortcuts) {
                    if ($shortcut.BaseName -like "*$appName*") {
                        $shell = New-Object -ComObject WScript.Shell
                        $shortcutPath = $shell.CreateShortcut($shortcut.FullName)
                        Write-Host "`n🔗 Raccourci trouvé : $($shortcut.FullName)" -ForegroundColor Cyan
                        Write-Host "   → Cible : $($shortcutPath.TargetPath)" -ForegroundColor Gray
                    }
                }
            }
        }
    }

    function Search-Registry {
        param([string]$appName)

        $registryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        $found = $false

        foreach ($regPath in $registryPaths) {
            $apps = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue | Where-Object {
                $_.DisplayName -like "*$appName*"
            }

            foreach ($app in $apps) {
                Write-Host "`n🗂️ Trouvé dans le registre : $($app.DisplayName)" -ForegroundColor Cyan
                if ($app.InstallLocation) {
                    Write-Host "   → Dossier d'installation : $($app.InstallLocation)" -ForegroundColor Green
                }
                if ($app.InstallSource) {
                    Write-Host "   → Source d'installation : $($app.InstallSource)" -ForegroundColor Yellow
                }
                if ($app.UninstallString) {
                    Write-Host "   → Uninstall String : $($app.UninstallString)" -ForegroundColor Magenta
                }
                if ($app.Publisher) {
                    Write-Host "   → Éditeur : $($app.Publisher)" -ForegroundColor DarkCyan
                }
                if ($app.DisplayVersion) {
                    Write-Host "   → Version : $($app.DisplayVersion)" -ForegroundColor DarkGray
                }
                $found = $true
            }
        }

        if (-not $found) {
            Write-Host "`n❌ Aucun élément trouvé dans le registre pour '$appName'" -ForegroundColor Red
        }
    }

    function Search-StoreApps {
        param([string]$appName)

        $storeApps = Get-AppxPackage | Where-Object { $_.Name -like "*$appName*" }

        if ($storeApps.Count -gt 0) {
            foreach ($app in $storeApps) {
                Write-Host "`n🛍️ Application Microsoft Store trouvée :" -ForegroundColor Blue
                Write-Host "   → Nom : $($app.Name)"
                Write-Host "   → Version : $($app.Version)"
                Write-Host "   → Éditeur : $($app.Publisher)"
                Write-Host "   → Dossier : $($app.InstallLocation)" -ForegroundColor DarkGreen
            }
        } else {
            Write-Host "`n❌ Aucune application Microsoft Store trouvée pour '$appName'" -ForegroundColor DarkRed
        }
    }

    Write-Host "🔍 Recherche de : $AppName" -ForegroundColor Yellow
    Write-Host "---------------------------------------------"

    $appExe = if ($AppName.ToLower().EndsWith(".exe")) { $AppName } else { "$AppName.exe" }

    Search-SystemExecutable -exeName $appExe
    Search-Shortcuts -appName $AppName
    Search-Registry -appName $AppName
    Search-StoreApps -appName $AppName
}

#Export-ModuleMember -Function Find-AppPath
