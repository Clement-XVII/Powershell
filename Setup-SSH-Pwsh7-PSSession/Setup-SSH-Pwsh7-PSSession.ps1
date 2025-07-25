Write-Host "Connexion réseau détectée. Poursuite du script..."

# Vérifier l'état d'installation d'OpenSSH Server
$opensshStatus = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
if ($opensshStatus.State -ne "Installed") {
    Write-Host "Installation d'OpenSSH Server..."
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "OpenSSH Server est déjà installé"
}

# Démarrer et configurer le service sshd
Write-Host "Démarrage et configuration du service sshd..."
Start-Service sshd
Set-Service -Name sshd -StartupType "Automatic"

# Chemin du fichier de configuration sshd_config
$sshdConfigPath = "C:\ProgramData\ssh\sshd_config"

# Vérifier si le fichier sshd_config existe
if (-Not (Test-Path $sshdConfigPath)) {
    Write-Host "Erreur : Le fichier sshd_config est introuvable." -ForegroundColor Red
    exit 1
}

# Lire le contenu actuel du fichier
$content = Get-Content $sshdConfigPath -Raw

# Vérifier si la ligne PowerShell existe déjà
if ($content -notmatch "Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo") {
    # Modifier le fichier sshd_config
    $newContent = (Get-Content $sshdConfigPath) | ForEach-Object {
        # Gérer les autres paramètres
        if ($_ -match "#?\s*PasswordAuthentication\s+(yes|no)") {
            "PasswordAuthentication no"
        }
        elseif ($_ -match "#?\s*ChallengeResponseAuthentication\s+(yes|no)") {
            "ChallengeResponseAuthentication yes"
        }
        elseif ($_ -match "#?\s*PubkeyAuthentication\s+(yes|no)") {
            "PubkeyAuthentication yes"
        }
        elseif ($_ -match "^Subsystem\s+sftp\s+sftp-server\.exe\s*$") {
            "$_`nSubsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo"
        }
        else {
            $_
        }
    }

    # Écrire le nouveau contenu dans le fichier
    $newContent | Set-Content $sshdConfigPath

    Write-Host "Configuration mise à jour avec succès." -ForegroundColor Green
}
else {
    Write-Host "La configuration PowerShell existe déjà dans le fichier." -ForegroundColor Yellow
}

# Redémarrer le service sshd pour appliquer les changements
Write-Host "Redémarrage du service sshd..."aWrite-Host "Connexion réseau détectée. Poursuite du script..."

# Vérifier l'état d'installation d'OpenSSH Server
$opensshStatus = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
if ($opensshStatus.State -ne "Installed") {
    Write-Host "Installation d'OpenSSH Server..."
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "OpenSSH Server est déjà installé"
}

# Démarrer et configurer le service sshd
Write-Host "Démarrage et configuration du service sshd..."
Start-Service sshd
Set-Service -Name sshd -StartupType "Automatic"

# Chemin du fichier de configuration sshd_config
$sshdConfigPath = "C:\ProgramData\ssh\sshd_config"

# Vérifier si le fichier sshd_config existe
if (-Not (Test-Path $sshdConfigPath)) {
    Write-Host "Erreur : Le fichier sshd_config est introuvable." -ForegroundColor Red
    exit 1
}

# Lire le contenu actuel du fichier
$content = Get-Content $sshdConfigPath -Raw

# Vérifier si la ligne PowerShell existe déjà
if ($content -notmatch "Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo") {
    # Modifier le fichier sshd_config
    $newContent = (Get-Content $sshdConfigPath) | ForEach-Object {
        if ($_ -match "#?\s*PasswordAuthentication\s+(yes|no)") {
            "PasswordAuthentication no"
        }
        elseif ($_ -match "#?\s*ChallengeResponseAuthentication\s+(yes|no)") {
            "ChallengeResponseAuthentication yes"
        }
        elseif ($_ -match "#?\s*PubkeyAuthentication\s+(yes|no)") {
            "PubkeyAuthentication yes"
        }
        elseif ($_ -match "^Subsystem\s+sftp\s+sftp-server\.exe\s*$") {
            "$_`nSubsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo"
        }
        else {
            $_
        }
    }

    # Écrire le nouveau contenu dans le fichier
    $newContent | Set-Content $sshdConfigPath

    Write-Host "Configuration mise à jour avec succès." -ForegroundColor Green
}
else {
    Write-Host "La configuration PowerShell existe déjà dans le fichier." -ForegroundColor Yellow
}

# Redémarrer le service sshd pour appliquer les changements
Write-Host "Redémarrage du service sshd..."
Restart-Service sshd

# Définir la clé publique directement dans le script
$publicKey = "PUT_YOUR_SSH_KEY"

$adminAuthorizedKeysPath = "C:\ProgramData\ssh\administrators_authorized_keys"

# Ajouter la clé publique au fichier administrators_authorized_keys
Write-Host "Ajout de la clé publique SSH à administrators_authorized_keys..."
$publicKey | Set-Content -Force -Path $adminAuthorizedKeysPath

# Configurer les permissions pour le fichier administrators_authorized_keys
Write-Host "Configuration des permissions pour administrators_authorized_keys..."
icacls.exe "$adminAuthorizedKeysPath" /inheritance:r /grant "*S-1-5-32-544:F" /grant "SYSTEM:F"

Write-Host "Configuration terminée avec succès. Seules les connexions par clé sont désormais autorisées." -ForegroundColor Green

Restart-Service sshd


$publicKeyPath = "\\vm-dc\sysvol\cclgsl\scripts\id_ed25519.pub"  # Chemin de la clé publique sur la clé USB
$adminAuthorizedKeysPath = "C:\ProgramData\ssh\administrators_authorized_keys"

# Vérifier si la clé publique existe sur la clé USB
if (-Not (Test-Path $publicKeyPath)) {
    Write-Host "Erreur : La clé publique est introuvable dans $publicKeyPath." -ForegroundColor Red
    exit 1
}

# Copier la clé publique dans le fichier administrators_authorized_keys
Write-Host "Ajout de la clé publique SSH à administrators_authorized_keys..."
Get-Content $publicKeyPath | Add-Content -Force -Path $adminAuthorizedKeysPath

# Configurer les permissions pour le fichier administrators_authorized_keys
Write-Host "Configuration des permissions pour administrators_authorized_keys..."
icacls.exe "$adminAuthorizedKeysPath" /inheritance:r /grant "*S-1-5-32-544:F" /grant "SYSTEM:F"

Write-Host "Configuration terminée avec succès. Seules les connexions par clé sont désormais autorisées." -ForegroundColor Green





