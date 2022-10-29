Function Add-Play-Music
{
    $Session = Get-PSSession
    $cheminaudio = "C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\"

    $audio = Read-Host -Prompt "Enter the path of the WAV file ex: C:\test\meme.wav"
    Write-Host "Configured path: $audio `n" -ForegroundColor Green

    Copy-Item -Path $audio -Destination $cheminaudio -ToSession $Session

    $audiofile = Get-Item $audio
    $nomfile = $audiofile.Basename + $audiofile.Extension

    Invoke-Command -Session $Session -ScriptBlock { 
		$sound = new-Object System.Media.SoundPlayer;
		$sound.SoundLocation="C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\$Using:nomfile";
		$sound.Play();
    }
}