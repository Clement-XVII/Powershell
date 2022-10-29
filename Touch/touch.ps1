function touch {
    param (
        [string]$file
    )

    $dir = Split-Path $file

    if (Test-Path $file) {
        Get-Item $file
    } elseif ($dir -and !(Test-Path -LiteralPath $dir)) {
        $null = mkdir $dir
        $null = New-Item $file -ItemType File
    } else {
        $null = New-Item $file -ItemType File
    }
}