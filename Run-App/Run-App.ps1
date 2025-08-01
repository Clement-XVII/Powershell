function Run-App {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppName,

        [string]$From,

        [switch]$List
    )

    $results = @()
    $appExe = if ($AppName.ToLower().EndsWith(".exe")) { $AppName } else { "$AppName.exe" }

    # Analyse de -From (ex: store:classic)
    $sourceType = $null
    $filterName = $null
    if ($From -match '^(store|raccourci|reg|system)(:(.+))?$') {
        $sourceType = $matches[1]
        $filterName = $matches[3]
    }

    # --- 1. Système ---
    if (-not $sourceType -or $sourceType -eq "system") {
        $systemPaths = @(
            "$env:SystemRoot\System32",
            "$env:SystemRoot\SysWOW64",
            "$env:SystemRoot",
            "$env:ProgramFiles",
            "$env:ProgramFiles(x86)"
        )
        foreach ($path in $systemPaths) {
            $fullPath = Join-Path $path $appExe
            if (Test-Path $fullPath) {
                $results += [PSCustomObject]@{
                    Type = "Système"
                    Name = $appExe
                    Path = $fullPath
                }
            }
        }
    }

    # --- 2. Raccourcis ---
    if (-not $sourceType -or $sourceType -eq "raccourci") {
        $shortcutFolders = @(
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        )
        foreach ($folder in $shortcutFolders) {
            if (Test-Path $folder) {
                $shortcuts = Get-ChildItem -Path $folder -Recurse -Filter *.lnk -ErrorAction SilentlyContinue
                foreach ($shortcut in $shortcuts) {
                    if ($shortcut.BaseName -like "*$AppName*") {
                        $shell = New-Object -ComObject WScript.Shell
                        $target = $shell.CreateShortcut($shortcut.FullName).TargetPath
                        if (Test-Path $target) {
                            $results += [PSCustomObject]@{
                                Type = "Raccourci"
                                Name = $shortcut.BaseName
                                Path = $target
                            }
                        }
                    }
                }
            }
        }
    }

    # --- 3. Registre ---
    if (-not $sourceType -or $sourceType -eq "reg") {
        $registryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        foreach ($regPath in $registryPaths) {
            $apps = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue | Where-Object {
                $_.DisplayName -like "*$AppName*" -and $_.InstallLocation
            }
            foreach ($app in $apps) {
                $exe = Get-ChildItem -Path $app.InstallLocation -Filter *.exe -Recurse -ErrorAction SilentlyContinue | Where-Object {
                    $_.Name -like "*$AppName*"
                } | Select-Object -First 1

                if ($exe) {
                    $results += [PSCustomObject]@{
                        Type = "Registre"
                        Name = $app.DisplayName
                        Path = $exe.FullName
                    }
                }
            }
        }
    }

    # --- 4. Microsoft Store ---
    if (-not $sourceType -or $sourceType -eq "store") {
        $storeApps = Get-StartApps | Where-Object { $_.Name -like "*$AppName*" }
        foreach ($app in $storeApps) {
            $results += [PSCustomObject]@{
                Type = "Store"
                Name = $app.Name
                Path = "shell:AppsFolder\$($app.AppID)"
            }
        }
    }

    # Nettoyage
    $results = $results | Sort-Object Path -Unique

    # Appliquer le filtre texte si présent (ex: store:classic)
    if ($sourceType -and $filterName) {
        $results = $results | Where-Object { $_.Type -eq $sourceType -and $_.Name -like "*$filterName*" }
    } elseif ($sourceType) {
        $results = $results | Where-Object { $_.Type -eq $sourceType }
    }

    if ($results.Count -eq 0) {
        Write-Host "❌ Aucune application trouvée pour '$AppName'" -ForegroundColor Red
        return
    }

    $selected = $null

    if ($List) {
        Write-Host "`n🧩 Plusieurs correspondances trouvées :"
        for ($i = 0; $i -lt $results.Count; $i++) {
            Write-Host "[$i] [$($results[$i].Type)] $($results[$i].Name) → $($results[$i].Path)"
        }
        $choice = Read-Host "Entrez le numéro de l'application à lancer"
        if ($choice -notmatch '^\d+$' -or [int]$choice -ge $results.Count) {
            Write-Host "❌ Choix invalide." -ForegroundColor Red
            return
        }
        $selected = $results[[int]$choice]
        Write-Host "`n🚀 Lancement de : $($selected.Name)" -ForegroundColor Green
    }
    else {
        # 🧠 Auto : priorité logique
        $priority = @("Raccourci", "Registre", "Système", "Store")
        foreach ($type in $priority) {
            $match = $results | Where-Object { $_.Type -eq $type } | Select-Object -First 1
            if ($match) {
                $selected = $match
                break
            }
        }
        Write-Host "`n🚀 Lancement automatique : $($selected.Name) [$($selected.Type)]" -ForegroundColor Green
    }

    try {
        if ($selected.Type -eq "Store") {
            Start-Process $selected.Path
        } else {
            Start-Process -FilePath $selected.Path
        }
    } catch {
        Write-Host "❌ Erreur lors du lancement : $_" -ForegroundColor Red
    }
}
