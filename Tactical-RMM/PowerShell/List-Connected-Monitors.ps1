# Define a function to convert an array of integers to characters
Function ConvertTo-Char ($Array) {
    $Output = ''
    # Iterate through each integer in the array and convert it to a character
    ForEach($char in $Array) { 
        $Output += [char]$char -join ""
    }
    return $Output
}

# Define a function to convert manufacturer codes to manufacturer names
Function ConvertTo-Manufacturer ($Code) {
    $Output = ''
    # Initialize monitor manufacturers
    $Manufacturer = @(
        [pscustomobject]@{'Monitor Manufacturer Code'='ACI';'Monitor Manufacturer'='Asus (ASUSTeK Computer Inc.)'}
        [pscustomobject]@{'Monitor Manufacturer Code'='ACR';'Monitor Manufacturer'='Acer America Corp.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='ACT';'Monitor Manufacturer'='Targa'}
        [pscustomobject]@{'Monitor Manufacturer Code'='ADI';'Monitor Manufacturer'='ADI Corporation'}
        [pscustomobject]@{'Monitor Manufacturer Code'='AMW';'Monitor Manufacturer'='AMW'}
        [pscustomobject]@{'Monitor Manufacturer Code'='AOC';'Monitor Manufacturer'='AOC International (USA) Ltd.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='API';'Monitor Manufacturer'='Acer America Corp.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='APP';'Monitor Manufacturer'='Apple Computer, Inc.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='ART';'Monitor Manufacturer'='ArtMedia'}
        [pscustomobject]@{'Monitor Manufacturer Code'='AST';'Monitor Manufacturer'='AST Research'}
        [pscustomobject]@{'Monitor Manufacturer Code'='AUO';'Monitor Manufacturer'='AU Optronics'}
        [pscustomobject]@{'Monitor Manufacturer Code'='BMM';'Monitor Manufacturer'='BMM'}
        [pscustomobject]@{'Monitor Manufacturer Code'='BNQ';'Monitor Manufacturer'='BenQ Corporation'}
        [pscustomobject]@{'Monitor Manufacturer Code'='BOE';'Monitor Manufacturer'='BOE Display Technology'}
        [pscustomobject]@{'Monitor Manufacturer Code'='CPL';'Monitor Manufacturer'='Compal Electronics, Inc. / ALFA'}
        [pscustomobject]@{'Monitor Manufacturer Code'='CPQ';'Monitor Manufacturer'='COMPAQ Computer Corp.'}
		[pscustomobject]@{'Monitor Manufacturer Code'='CMN';'Monitor Manufacturer'='Chi Mei Innolux'}
        [pscustomobject]@{'Monitor Manufacturer Code'='CTX';'Monitor Manufacturer'='CTX - Chuntex Electronic Co.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='DEC';'Monitor Manufacturer'='Digital Equipment Corporation'}
        [pscustomobject]@{'Monitor Manufacturer Code'='DEL';'Monitor Manufacturer'='Dell Computer Corp.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='DPC';'Monitor Manufacturer'='Delta Electronics, Inc.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='DWE';'Monitor Manufacturer'='Daewoo Telecom Ltd'}
        [pscustomobject]@{'Monitor Manufacturer Code'='ECS';'Monitor Manufacturer'='ELITEGROUP Computer Systems'}
        [pscustomobject]@{'Monitor Manufacturer Code'='EIZ';'Monitor Manufacturer'='EIZO'}
		[pscustomobject]@{'Monitor Manufacturer Code'='ENC';'Monitor Manufacturer'='EIZO'}
        [pscustomobject]@{'Monitor Manufacturer Code'='EPI';'Monitor Manufacturer'='Envision Peripherals, Inc.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='FCM';'Monitor Manufacturer'='Funai Electric Company of Taiwan'}
        [pscustomobject]@{'Monitor Manufacturer Code'='FUS';'Monitor Manufacturer'='Fujitsu Siemens'}
        [pscustomobject]@{'Monitor Manufacturer Code'='GSM';'Monitor Manufacturer'='LG Electronics Inc. (GoldStar Technology, Inc.)'}
        [pscustomobject]@{'Monitor Manufacturer Code'='GWY';'Monitor Manufacturer'='Gateway 2000'}
        [pscustomobject]@{'Monitor Manufacturer Code'='HEI';'Monitor Manufacturer'='Hyundai Electronics Industries Co., Ltd.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='HIQ';'Monitor Manufacturer'='Hyundai ImageQuest'}
        [pscustomobject]@{'Monitor Manufacturer Code'='HIT';'Monitor Manufacturer'='Hitachi'}
        [pscustomobject]@{'Monitor Manufacturer Code'='HSD';'Monitor Manufacturer'='Hannspree Inc'}
        [pscustomobject]@{'Monitor Manufacturer Code'='HSL';'Monitor Manufacturer'='Hansol Electronics'}
        [pscustomobject]@{'Monitor Manufacturer Code'='HTC';'Monitor Manufacturer'='Hitachi Ltd. / Nissei Sangyo America Ltd.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='HWP';'Monitor Manufacturer'='Hewlett Packard (HP)'}
        [pscustomobject]@{'Monitor Manufacturer Code'='HPN';'Monitor Manufacturer'='Hewlett Packard (HP)'}
        [pscustomobject]@{'Monitor Manufacturer Code'='IBM';'Monitor Manufacturer'='IBM PC Company'}
        [pscustomobject]@{'Monitor Manufacturer Code'='ICL';'Monitor Manufacturer'='Fujitsu ICL'}
        [pscustomobject]@{'Monitor Manufacturer Code'='IFS';'Monitor Manufacturer'='InFocus'}
        [pscustomobject]@{'Monitor Manufacturer Code'='IQT';'Monitor Manufacturer'='Hyundai'}
        [pscustomobject]@{'Monitor Manufacturer Code'='IVM';'Monitor Manufacturer'='Idek Iiyama North America, Inc.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='KDS';'Monitor Manufacturer'='KDS USA'}
        [pscustomobject]@{'Monitor Manufacturer Code'='KFC';'Monitor Manufacturer'='KFC Computek'}
        [pscustomobject]@{'Monitor Manufacturer Code'='LEN';'Monitor Manufacturer'='Lenovo'}
        [pscustomobject]@{'Monitor Manufacturer Code'='LGD';'Monitor Manufacturer'='LG Display'}
        [pscustomobject]@{'Monitor Manufacturer Code'='LKM';'Monitor Manufacturer'='ADLAS / AZALEA'}
        [pscustomobject]@{'Monitor Manufacturer Code'='LNK';'Monitor Manufacturer'='LINK Technologies, Inc.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='LPL';'Monitor Manufacturer'='LG Philips'}
        [pscustomobject]@{'Monitor Manufacturer Code'='LTN';'Monitor Manufacturer'='Lite-On'}
        [pscustomobject]@{'Monitor Manufacturer Code'='MAG';'Monitor Manufacturer'='MAG InnoVision'}
        [pscustomobject]@{'Monitor Manufacturer Code'='MAX';'Monitor Manufacturer'='Maxdata Computer GmbH'}
        [pscustomobject]@{'Monitor Manufacturer Code'='MEI';'Monitor Manufacturer'='Panasonic Comm. & Systems Co.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='MEL';'Monitor Manufacturer'='Mitsubishi Electronics'}
        [pscustomobject]@{'Monitor Manufacturer Code'='MIR';'Monitor Manufacturer'='miro Computer Products AG'}
        [pscustomobject]@{'Monitor Manufacturer Code'='MTC';'Monitor Manufacturer'='MITAC'}
		[pscustomobject]@{'Monitor Manufacturer Code'='MSH';'Monitor Manufacturer'='Microsoft Hyper-V'}
        [pscustomobject]@{'Monitor Manufacturer Code'='NAN';'Monitor Manufacturer'='NANAO'}
        [pscustomobject]@{'Monitor Manufacturer Code'='NEC';'Monitor Manufacturer'='NEC Technologies, Inc.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='NOK';'Monitor Manufacturer'='Nokia'}
        [pscustomobject]@{'Monitor Manufacturer Code'='NVD';'Monitor Manufacturer'='Nvidia'}
        [pscustomobject]@{'Monitor Manufacturer Code'='OQI';'Monitor Manufacturer'='OPTIQUEST'}
        [pscustomobject]@{'Monitor Manufacturer Code'='PBN';'Monitor Manufacturer'='Packard Bell'}
        [pscustomobject]@{'Monitor Manufacturer Code'='PCK';'Monitor Manufacturer'='Daewoo'}
        [pscustomobject]@{'Monitor Manufacturer Code'='PDC';'Monitor Manufacturer'='Polaroid'}
        [pscustomobject]@{'Monitor Manufacturer Code'='PGS';'Monitor Manufacturer'='Princeton Graphic Systems'}
        [pscustomobject]@{'Monitor Manufacturer Code'='PHL';'Monitor Manufacturer'='Philips Consumer Electronics Co'}
        [pscustomobject]@{'Monitor Manufacturer Code'='PRT';'Monitor Manufacturer'='Princeton'}
        [pscustomobject]@{'Monitor Manufacturer Code'='REL';'Monitor Manufacturer'='Relisys'}
        [pscustomobject]@{'Monitor Manufacturer Code'='SAM';'Monitor Manufacturer'='Samsung'}
        [pscustomobject]@{'Monitor Manufacturer Code'='SEC';'Monitor Manufacturer'='Seiko Epson Corporation'}
		[pscustomobject]@{'Monitor Manufacturer Code'='SDC';'Monitor Manufacturer'='Smart Display Company'}
        [pscustomobject]@{'Monitor Manufacturer Code'='SMC';'Monitor Manufacturer'='Samtron'}
        [pscustomobject]@{'Monitor Manufacturer Code'='SMI';'Monitor Manufacturer'='Smile'}
        [pscustomobject]@{'Monitor Manufacturer Code'='SNI';'Monitor Manufacturer'='Siemens Nixdorf'}
        [pscustomobject]@{'Monitor Manufacturer Code'='SNY';'Monitor Manufacturer'='Sony Corporation'}
        [pscustomobject]@{'Monitor Manufacturer Code'='SPT';'Monitor Manufacturer'='Sceptre'}
        [pscustomobject]@{'Monitor Manufacturer Code'='SRC';'Monitor Manufacturer'='Shamrock Technology'}
        [pscustomobject]@{'Monitor Manufacturer Code'='STN';'Monitor Manufacturer'='Samtron'}
        [pscustomobject]@{'Monitor Manufacturer Code'='STP';'Monitor Manufacturer'='Sceptre'}
        [pscustomobject]@{'Monitor Manufacturer Code'='TAT';'Monitor Manufacturer'='Tatung Co. of America, Inc.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='TRL';'Monitor Manufacturer'='Royal Information Company'}
        [pscustomobject]@{'Monitor Manufacturer Code'='TSB';'Monitor Manufacturer'='Toshiba, Inc.'}
        [pscustomobject]@{'Monitor Manufacturer Code'='UNM';'Monitor Manufacturer'='Unisys Corporation'}
        [pscustomobject]@{'Monitor Manufacturer Code'='VSC';'Monitor Manufacturer'='ViewSonic Corporation'}
        [pscustomobject]@{'Monitor Manufacturer Code'='WTC';'Monitor Manufacturer'='Wen Technology'}
        [pscustomobject]@{'Monitor Manufacturer Code'='ZCM';'Monitor Manufacturer'='Zenith Data Systems'}
    )
    # Retrieve the manufacturer name based on the code
    $Output = $Manufacturer | Where-Object {$_.'Monitor Manufacturer Code' -eq $Code} | select -ExpandProperty 'Monitor Manufacturer'
    # Return the manufacturer name if found, otherwise return the code
    If (!$Output) {
        Return $Code
    } else {
        Return $Output
    }
}

# Initialize the result array and counter
$Results = @()
$i = 0

# Attempt to retrieve monitor information using WMI
Try {
    $Query = Get-WmiObject -Query "Select * FROM WMIMonitorID" -Namespace root\wmi -ErrorAction Stop
	
    # Determine the total number of monitors connected
	if ($Query.count) {
		$totalMonitors = $Query.count
	} else {
		$totalMonitors = 1
	}

    # Iterate through each monitor retrieved
    ForEach ($Monitor in $Query) {
        # Retrieve connection type information
        $QueryConn = Get-WmiObject -Query "Select * from WmiMonitorConnectionParams" -Namespace root\wmi -ErrorAction Stop | where {$_.InstanceName -eq $Monitor.InstanceName}
        Switch ($QueryConn.VideoOutputTechnology) {
            -2  {$Connectiontype="UNINITIALIZED"}
            -1  {$Connectiontype="OTHER"}
            0   {$Connectiontype="HD15 (VGA)"}
            1   {$Connectiontype="SVIDEO"}
            2   {$Connectiontype="COMPOSITE_VIDEO"}
            3   {$Connectiontype="COMPOSITE_VIDEO"}
            4   {$Connectiontype="DVI"}
            5   {$Connectiontype="HDMI"}
            6   {$Connectiontype="LVDS"}
            9   {$Connectiontype="LDI"}
            10  {$Connectiontype="Displayport"}
            11  {$Connectiontype="Displayport Embedded"}
            14  {$Connectiontype="SDTVDONGLE"}
            15  {$Connectiontype="Miracast"}
			4294967295   {$Connectiontype="Remote Desktop Console"}
            Default {$Connectiontype="Notebook or unknown"}
        }
        
        # Retrieve preferred display mode
        $QuerySourceMode = Get-WmiObject -Query "SELECT * FROM WmiMonitorListedSupportedSourceModes" -Namespace root\wmi -ErrorAction Stop | where {$_.InstanceName -eq $Monitor.InstanceName}
        $preferredMode = "$($QuerySourceMode.MonitorSourceModes[$QuerySourceMode.PreferredMonitorSourceModeIndex].HorizontalActivePixels)x$($QuerySourceMode.MonitorSourceModes[$QuerySourceMode.PreferredMonitorSourceModeIndex].VerticalActivePixels)"
        
        # Retrieve current brightness if supported by hardware
        $QueryBrightness = Get-WmiObject -Query "SELECT * FROM WmiMonitorBrightness" -Namespace root\wmi -ErrorAction SilentlyContinue | where {$_.InstanceName -eq $Monitor.InstanceName}
        If (!$QueryBrightness) {
            $Brightness = 'Not available'
        } else {
            $Brightness = $QueryBrightness.CurrentBrightness
        }

        # Construct the result object for the current monitor
        $Results += New-Object PSObject -Property @{
             Manufacturer = ConvertTo-Manufacturer(ConvertTo-Char($Monitor.ManufacturerName))
             Name = ConvertTo-Char($Monitor.userfriendlyname)
             'Serial Number' = ConvertTo-Char($Monitor.serialnumberid)
             'Week Of Manufacture' = $Monitor.WeekOfManufacture
             'Year Of Manufacture' = $Monitor.YearOfManufacture
             'Connection Type' = $Connectiontype
             'Monitor Active' = $Monitor.Active
             'Total Connected Monitors' = $totalMonitors
             'Current brightness' = $Brightness
             'Preferred display mode' = $preferredMode
             A1_Key = ([string]$i + ':' + [string]("$env:COMPUTERNAME"))
        }
    $i++        
    }
    # Output the results
    $Results
}
Catch {
    # Handle exceptions gracefully and construct an error result object
    if ($Query.count) {
		$totalMonitors = $Query.count
	} else {
		$totalMonitors = 0
	}
	
    $Results += New-Object PSObject -Property @{
         Manufacturer = "Not available (possibly no monitors connected)"
         Name = $Error[0]
         'Serial Number' = ConvertTo-Char($Monitor.serialnumberid)
         'Week Of Manufacture' = $Monitor.WeekOfManufacture
         'Year Of Manufacture' = $Monitor.YearOfManufacture
         'Connection Type' = $Connectiontype
         'Monitor Active' = "false"
         'Total Connected Monitors' = $totalMonitors
         'Current brightness' = $Brightness
         'Preferred display mode' = $preferredMode
         A1_Key = ([string]$i + ':' + [string]("$env:COMPUTERNAME"))
    }
    # Output the error result
    $Results
}