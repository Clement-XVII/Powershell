function Find-App {
    param (
        [string]$AppName,
        [switch]$ListAll,
        [switch]$Executables,
        [switch]$Shortcuts,
        [switch]$Registry,
        [switch]$Store
    )

    function Search-SystemExecutable {
        param([string]$exeName, [switch]$All)

        $systemPaths = @(
            "$env:SystemRoot\System32",
            "$env:SystemRoot\SysWOW64",
            "$env:SystemRoot",
            "$env:ProgramFiles",
            "$env:ProgramFiles(x86)"
        )

        foreach ($path in $systemPaths) {
            if (Test-Path $path) {
                if ($All) {
                    # Recherche complète et lente
                    $executables = Get-ChildItem -Path $path -Filter *.exe -Recurse -ErrorAction SilentlyContinue
                    foreach ($exe in $executables) {
                        Write-Host "`n✅ Exécutable système trouvé : $($exe.FullName)" -ForegroundColor Green
                    }
                }
                else {
                    # Recherche ciblée rapide (pas de recurse)
                    $fullPath = Join-Path $path $exeName
                    if (Test-Path $fullPath) {
                        Write-Host "`n✅ Exécutable système trouvé : $fullPath" -ForegroundColor Green
                    }
                }
            }
        }
    }

    function Search-Shortcuts {
        param([string]$appName, [switch]$All)

        $shortcutFolders = @(
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        )

        foreach ($folder in $shortcutFolders) {
            if (Test-Path $folder) {
                $shortcuts = Get-ChildItem -Path $folder -Recurse -Filter *.lnk -ErrorAction SilentlyContinue
                foreach ($shortcut in $shortcuts) {
                    if ($All -or $shortcut.BaseName -like "*$appName*") {
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
        param([string]$appName, [switch]$All)

        $registryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        $found = $false

        foreach ($regPath in $registryPaths) {
            $apps = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue | Where-Object {
                $All -or ($_.DisplayName -like "*$appName*")
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

        if (-not $found -and -not $All) {
            Write-Host "`n❌ Aucun élément trouvé dans le registre pour '$appName'" -ForegroundColor Red
        }
    }

    function Search-StoreApps {
        param([string]$appName, [switch]$All)

        $storeApps = Get-AppxPackage | Where-Object { $All -or $_.Name -like "*$appName*" }

        if ($storeApps.Count -gt 0) {
            foreach ($app in $storeApps) {
                Write-Host "`n🛍️ Application Microsoft Store trouvée :" -ForegroundColor Blue
                Write-Host "   → Nom : $($app.Name)"
                Write-Host "   → Version : $($app.Version)"
                Write-Host "   → Éditeur : $($app.Publisher)"
                Write-Host "   → Dossier : $($app.InstallLocation)" -ForegroundColor DarkGreen
            }
        }
        elseif (-not $All) {
            Write-Host "`n❌ Aucune application Microsoft Store trouvée pour '$appName'" -ForegroundColor DarkRed
        }
    }

    # Logique principale
    if ($ListAll) {
        Write-Host "📋 Liste complète de toutes les applications et raccourcis" -ForegroundColor Yellow
        Write-Host "---------------------------------------------------------"

        if ($Executables -or -not ($Executables -or $Shortcuts -or $Registry -or $Store)) {
            Search-SystemExecutable -exeName "" -All
        }
        if ($Shortcuts -or -not ($Executables -or $Shortcuts -or $Registry -or $Store)) {
            Search-Shortcuts -appName "" -All
        }
        if ($Registry -or -not ($Executables -or $Shortcuts -or $Registry -or $Store)) {
            Search-Registry -appName "" -All
        }
        if ($Store -or -not ($Executables -or $Shortcuts -or $Registry -or $Store)) {
            Search-StoreApps -appName "" -All
        }
    }
    elseif ($AppName) {
        Write-Host "🔍 Recherche de : $AppName" -ForegroundColor Yellow
        Write-Host "---------------------------------------------"

        $appExe = if ($AppName.ToLower().EndsWith(".exe")) { $AppName } else { "$AppName.exe" }

        if (-not ($Executables -or $Shortcuts -or $Registry -or $Store)) {
            # Par défaut : tout rechercher
            Search-SystemExecutable -exeName $appExe
            Search-Shortcuts -appName $AppName
            Search-Registry -appName $AppName
            Search-StoreApps -appName $AppName
        }
        else {
            if ($Executables) { Search-SystemExecutable -exeName $appExe }
            if ($Shortcuts) { Search-Shortcuts -appName $AppName }
            if ($Registry)   { Search-Registry -appName $AppName }
            if ($Store)      { Search-StoreApps -appName $AppName }
        }
    }
    else {
        Write-Host "❌ Spécifie un -AppName ou utilise -ListAll pour tout afficher." -ForegroundColor Red
    }
}
