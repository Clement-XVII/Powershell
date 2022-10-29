Function Play-Music()
{
    $Session = Get-PSSession
    $audio = Read-Host -Prompt "Enter the name of the WAV file ex: meme.wav"
    Write-Host "Configured path: $audio `n" -ForegroundColor Green
    Invoke-Command -Session $Session -ScriptBlock { 
        

        $sound = new-Object System.Media.SoundPlayer;
        $sound.SoundLocation="C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\$Using:audio";
        $sound.Play();
    }
}