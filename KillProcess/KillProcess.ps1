Function KillProcess {
$listapps = Get-Process | Select-Object ProcessName
echo $listapps | Format-Wide -Column 6
$Application = Read-Host -Prompt "Entrer le nom de l'application"
    if (-not($Application)) {
        Write-Host "$Application `n" -ForegroundColor Green
    }
    elseif ($Application) {
        Write-Host "Nom de l'application: $Application `n" -ForegroundColor Green
    }
  foreach($App in $listapps)
  {
     if($App -match $Application)
        {
        $name = $App
        
        }
  }
echo $name.ProcessName
Stop-process -Name $name.ProcessName -Force   
}