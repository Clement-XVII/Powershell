dism /Mount-wim /wimfile:D:\temporaire\Install.wim /index:1 /MountDir:D:\temporaire\mount
dism /Image:D:\temporaire\mount /set-ProductKey:W269N-WFGWX-YVC9B-4J6C9-T83GX
dism /Image:D:\temporaire\mount /enable-feature /featurename:TelnetClient /all

$apps=@( 	
	"9E2F88E3.Twitter"
	"ClearChannelRadioDigital.iHeartRadio"
	"Flipboard.Flipboard"
	"king.com.CandyCrushSodaSaga"
	"Microsoft.3DBuilder"
	"Microsoft.BingFinance"
	"Microsoft.BingNews"
	"Microsoft.BingSports"
	"Microsoft.BingWeather"
	"Microsoft.CommsPhone"
	"Microsoft.Getstarted"
	"Microsoft.Messaging"
	"Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
	"Microsoft.Office.OneNote"
	"Microsoft.Office.Sway"
	"Microsoft.People"
	"Microsoft.SkypeApp"
	"Microsoft.Windows.Phone"
	#"Microsoft.Windows.Photos"
	#"Microsoft.WindowsAlarms"
	#"Microsoft.WindowsCalculator"
	#"Microsoft.WindowsCamera"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsPhone"
	"Microsoft.WindowsSoundRecorder"
	"Microsoft.XboxApp"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"microsoft.windowscommunicationsapps"
	"Microsoft.MinecraftUWP"
	"ShazamEntertainmentLtd.Shazam"		
)

foreach ($app in $apps) {	
	Get-AppXProvisionedPackage -path D:\temporaire\mount | where DisplayName -EQ $app | Remove-AppxProvisionedPackage
    }

dism /unmount-wim /mountdir:D:\temporaire\mount /commit