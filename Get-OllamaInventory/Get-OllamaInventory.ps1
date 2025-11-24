<#
.SYNOPSIS
    Scan d'instances Ollama → tableau récapitulatif + liste détaillée des modèles.
    Export CSV optionnel avec gestion du verrouillage de fichier.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$IpListPath,

    [int]$TimeoutSec = 10,

    [string]$OutputCsv,          # Si indiqué → export CSV
    [switch]$ExpandAllModels     # (déjà présent) : CSV détaillé ligne‑par‑modèle
)

# -------------------------------------------------
# 1️⃣  Fonctions utilitaires (inchangées)
function Convert-ModelSizeToFloat {
    param([string]$SizeString)
    if (-not $SizeString) { return 0 }
    $numeric = $SizeString -replace '[Bb]','' -replace ',', '.'
    [double]::Parse($numeric,[System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-OllamaModelInfo {
    param(
        [string]$Server,
        [int]$Port = 11434,
        [int]$TimeoutSec = 10
    )
    $uri = "http://$Server`:$Port/api/tags"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec $TimeoutSec -ErrorAction Stop
    }
    catch {
        return [pscustomobject]@{
            Server       = $Server
            Success      = $false
            ErrorMessage = $_.Exception.Message
            LargestModel = ''
            LargestSize  = 0
            ModelCount   = 0
            Models       = @()
        }
    }

    $models = $response.models
    if (-not $models) {
        return [pscustomobject]@{
            Server       = $Server
            Success      = $true
            ErrorMessage = ''
            LargestModel = ''
            LargestSize  = 0
            ModelCount   = 0
            Models       = @()
        }
    }

    $maxSize   = 0
    $maxModel  = ''
    $allModels = @()

    foreach ($m in $models) {
        $sizeNum = Convert-ModelSizeToFloat -SizeString $m.size
        $allModels += [pscustomobject]@{ Name = $m.name; Size = $sizeNum }
        if ($sizeNum -gt $maxSize) {
            $maxSize  = $sizeNum
            $maxModel = $m.name
        }
    }

    return [pscustomobject]@{
        Server       = $Server
        Success      = $true
        ErrorMessage = ''
        LargestModel = $maxModel
        LargestSize  = $maxSize
        ModelCount   = $models.Count
        Models       = $allModels
    }
}
# -------------------------------------------------
# 2️⃣  Lecture du fichier d’IP/hostnames
$servers = Get-Content -Path $IpListPath |
           Where-Object { $_ -and -not $_.StartsWith('#') } |
           ForEach-Object { $_.Trim() }

if (-not $servers) { Write-Error "Le fichier ne contient aucune adresse valide."; exit 1 }

# -------------------------------------------------
# 3️⃣  Récupération des infos (parallèle si PowerShell 7)
$ps7 = $PSVersionTable.PSVersion.Major -ge 7
if ($ps7) {
    $results = $servers | ForEach-Object -Parallel {
        . $using:MyInvocation.MyCommand.Path   # charge les fonctions dans le runspace parallèle
        Get-OllamaModelInfo -Server $_ -TimeoutSec $using:TimeoutSec
    } -ThrottleLimit 20
}
else {
    $results = foreach ($srv in $servers) {
        Get-OllamaModelInfo -Server $srv -TimeoutSec $TimeoutSec
    }
}

# -------------------------------------------------
# 4️⃣  Tri (serveurs qui répondent d’abord, puis par taille décroissante)
$sorted = $results |
    Sort-Object -Property @{Expression={ -not $_.Success }},
                           @{Expression={ $_.LargestSize }; Descending=$true }

# -------------------------------------------------
# 5️⃣  **Affichage du tableau** (exactement votre format‑table)
Write-Host "`n=== Tableau récapitulatif ===`n" -ForegroundColor Cyan

$sorted | Format-Table -AutoSize `
    @{Label='Server';       Expression={ $_.Server }},
    @{Label='OK?';          Expression={ if ($_.Success) { '✔' } else { '✖' } }},
    @{Label='#Models';     Expression={ $_.ModelCount }},
    @{Label='Largest Model';Expression={ $_.LargestModel }},
    @{Label='Size (B)';    Expression={ $_.LargestSize }},
    @{Label='Models';      Expression={ ($_.Models.Name -join ', ') }} | Out-String | Write-Host

# -------------------------------------------------
# 6️⃣  **Affichage détaillé** (liste ligne‑par‑ligne, comme avant)
Write-Host "`n=== Détail de chaque serveur ===`n" -ForegroundColor Cyan

foreach ($srv in $sorted) {
    $ok = if ($srv.Success) { '✔' } else { '✖' }
    Write-Host ("Server: {0}   OK? {1}   #Models: {2}" -f $srv.Server,$ok,$srv.ModelCount) -ForegroundColor Yellow

    if ($srv.Success) {
        Write-Host ("  → Plus gros modèle : {0}  ({1} B)" -f $srv.LargestModel,$srv.LargestSize) -ForegroundColor Green

        if ($srv.Models.Count -gt 0) {
            Write-Host "  → Tous les modèles installés :" -ForegroundColor White
            foreach ($m in $srv.Models) {
                $sizeTxt = if ($m.Size) { "$($m.Size) B" } else { "N/A" }
                $line = "      • {0}  ({1})" -f $m.Name,$sizeTxt
                if ($m.Name -eq $srv.LargestModel) {
                    Write-Host $line -ForegroundColor Green
                }
                else {
                    Write-Host $line -ForegroundColor Gray
                }
            }
        }
    }
    else {
        Write-Host ("  → Erreur : {0}" -f $srv.ErrorMessage) -ForegroundColor Red
    }

    Write-Host ""   # séparateur visuel
}

# -------------------------------------------------
# 7️⃣  **Export CSV** (gestion du verrouillage)
if ($OutputCsv) {
    # Si le fichier existe déjà, on tente de le supprimer.
    if (Test-Path $OutputCsv) {
        try {
            Remove-Item -Path $OutputCsv -Force -ErrorAction Stop
        }
        catch {
            # Le fichier est peut‑être verrouillé (ex. ouvert dans Excel)
            Write-Warning "Le fichier CSV est verrouillé. 5 secondes d’attente avant nouvelle tentative..."
            Start-Sleep -Seconds 5
            try {
                Remove-Item -Path $OutputCsv -Force -ErrorAction Stop
            }
            catch {
                Write-Error "Impossible de libérer le fichier CSV : $($_.Exception.Message)"
                # On continue quand même, mais on ne pourra pas écrire.
                $skipExport = $true
            }
        }
    }

    if (-not $skipExport) {
        try {
            if ($ExpandAllModels) {
                # CSV détaillé : chaque ligne = un modèle
                $sorted | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8 -Force
            }
            else {
                # CSV compact : une ligne par serveur
                $sorted | Select-Object `
                    Server,
                    @{Name='OK?';Expression={ $_.Success }},
                    ModelCount,
                    LargestModel,
                    LargestSize,
                    @{Name='Models';Expression={ ($_.Models.Name -join ', ') }} |
                    Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8 -Force
            }
            Write-Host "`nCSV exporté avec succès → $OutputCsv" -ForegroundColor Green
        }
        catch {
            Write-Error "Export‑CSV a échoué : $($_.Exception.Message)"
        }
    }
}