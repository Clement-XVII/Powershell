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