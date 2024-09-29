### List Browser Extensions - Chrome, Edge Chromium, and Firefox

### Functions
function GetChromeExtensions {
    param (
        $UserPath
    )

    ### Variables
    [string]$chromePath = $UserPath + "\AppData\Local\Google\Chrome\User Data"
    [array]$excludeExtenionIDs = 'nmmhkkegccagdldgiimedpiccmgmieda','mhjfbmdgcfjbbpaeojofohoefgiehjai','pkedcjkdefgpdelpbcmbmeomcjbeemfm','Temp' # Exclude Default Chrome Extensions

    ### Find all user Chrome profiles
    if(Test-Path $chromePath)
    {
        ### Get profile data from Local State json file
        $localStatePath = $($chromePath + "\Local State")
        if(Test-Path $localStatePath)
        {
            $localState = Get-Content -Raw -Path $localStatePath | ConvertFrom-Json
            $profileNames = $localState.profile.info_cache.psobject.Properties.name
            
            ### Loop through each Chrome profile and gather extension
            foreach($profileName in $profileNames)
            {
                $profilePath = $($chromePath + "\$profileName" + "\Extensions")
                $extensions = (Get-ChildItem -Path $profilePath -Exclude $excludeExtenionIDs -ErrorAction SilentlyContinue)
                if($extensions)
                {
                    foreach($ext in $extensions)
                    {
                        $manifestFile = Get-ChildItem -Path $ext.FullName -Recurse -Include "manifest.json"  | sort -Descending CreationTime | select -First 1
                        $jsonData = $(Get-Content -Raw -Path $($manifestFile.FullName) | ConvertFrom-Json)
                        $extensionName = $jsonData.name
                        if(($extensionName -like "*MSG*") -or ($extensionName -eq ''))
                        {
                            $extNameSearchPath = Get-ChildItem $ext.FullName | sort -Descending CreationTime | select -First 1
                            $extJsonDataPath = Get-ChildItem "$($extNameSearchPath.FullName)\_locales\en*" | select -First 1
                            $extJsonData = $(Get-Content -Raw -Path $($extJsonDataPath.FullName + "\messages.json") | ConvertFrom-Json)
                            if($extJsonData.extname)
                            {
                                $extensionName = $extJsonData.extname.message
                            }
                            elseif ($extJsonData.appName) 
                            {    
                                $extensionName = $extJsonData.appName.message
                            }
                            else
                            {
                                $extensionName = "Unknown"
                            }
                        }
                        $extensionID = $ext.Name
                        $extensionVersion = $jsonData.version
                        $extensionMostRecentVersion = $manifestFile | sort -Descending CreationTime | select -First 1
                        $installDate = Get-Date $(Get-Item $extensionMostRecentVersion.FullName).CreationTime -Format G
                        
                        [PSCustomObject]@{
                            Name = $extensionName
                            Version = $extensionVersion
                            Profile = $profileName
                            Browser = "Google Chrome"
                            Enabled = "Unknown"
                            InstallDate = $installDate
                            ID = $extensionID
                            User = $UserPath
                        }
                    }
                }
            }
        }
    }
}

function GetEdgeExtensions {
    param (
        $UserPath
    )
    ### Variables
    [string]$edgePath = $UserPath + "\AppData\Local\Microsoft\Edge\User Data"
    [array]$excludeExtenionIDs = 'Temp' # Exclude Default Edge Extensions

    ### Find all user Edge profiles
    if(Test-Path $edgePath)
    {
        ### Get profile data from Local State json file
        $localStatePath = $($edgePath + "\Local State")
        if(Test-Path $localStatePath)
        {
            $localState = Get-Content -Raw -Path $localStatePath | ConvertFrom-Json
            [array]$profileNames = $localState.profile.info_cache.psobject.Properties.name
            
            ### Loop through each Edge profile and gather extension
            foreach($profileName in $profileNames)
            {
                $profilePath = $($edgePath + "\$profileName" + "\Extensions")
                $extensions = (Get-ChildItem -Path $profilePath -Exclude $excludeExtenionIDs  -ErrorAction SilentlyContinue)
                if($extensions)
                {
                    foreach($ext in $extensions)
                    {
                        $manifestFile = Get-ChildItem -Path $ext.FullName -Recurse -Include "manifest.json" | sort -Descending CreationTime | select -First 1
                        $jsonData = $(Get-Content -Raw -Path $($manifestFile.FullName) | ConvertFrom-Json)
                        $extensionName = $jsonData.name
                        if(($extensionName -like "*MSG*") -or ($extensionName -eq ''))
                        {
                            $extNameSearchPath = Get-ChildItem $ext.FullName | sort -Descending CreationTime | select -First 1
                            $extJsonDataPath = Get-ChildItem "$($extNameSearchPath.FullName)\_locales\en*" | select -First 1
                            $extJsonData = $(Get-Content -Raw -Path $($extJsonDataPath.FullName + "\messages.json") | ConvertFrom-Json)
                            if($extJsonData.extname)
                            {
                                $extensionName = $extJsonData.extname.message
                            }
                            elseif ($extJsonData.appName) 
                            {    
                                $extensionName = $extJsonData.appName.message
                            }
                            else
                            {
                                $extensionName = "Unknown"
                            }
                        }
                        $extensionID = $ext.Name
                        $extensionVersion = $jsonData.version
                        $extensionMostRecentVersion = $manifestFile | sort -Descending CreationTime | select -First 1
                        $installDate = Get-Date $(Get-Item $extensionMostRecentVersion.FullName).CreationTime -Format G
                        
                        [PSCustomObject]@{
                            Name = $extensionName
                            Version = $extensionVersion
                            Profile = $profileName
                            Browser = "Microsft Edge"
                            Enabled = "Unknown"
                            InstallDate = $installDate
                            ID = $extensionID
                            User = $UserPath
                        }
                    }
                }
            }
        }
    }
}

function GetFirefoxExtensions {
    param (
        $UserPath
    )
    ### Variables
    [string]$firefoxPath = $UserPath + "\AppData\Roaming\Mozilla\Firefox"
    [array]$excludeExtenionIDs = 'app-builtin','app-system-defaults' # Exclude Default Firefox Extensions

    ### Find all user firewfox profiles
    if(Test-Path $firefoxPath)
    {
        ### Get profile data from profiles.ini file
        $profilesIni = $($firefoxPath + "\profiles.ini")
        if(Test-Path $profilesIni)
        {
            $profilesState = GetIniContent -FilePath $profilesIni | ConvertTo-Json | ConvertFrom-Json
            [array]$profileNames = $profilesState.psobject.Properties.name | where {($_ -match "Profile") -and -not($_ -match "Background")}
            
            ### Loop through each Firefox profile and gather extension
            foreach($profileName in $profileNames)
            {
                $profileInfo = $profilesState.$($profileName)
                $profilePath = $($firefoxPath + "\Profiles" + "\$($profileInfo.Path.split("/")[1])")
                if(Test-Path $profilePath)
                {
                    $extensionsPath = Get-ChildItem -Path $profilePath -File -Filter "extensions.json" -Recurse -ErrorAction SilentlyContinue
                    if($extensionsPath)
                    {
                        $extensions = Get-Content -Raw -Path $($extensionsPath).FullName -ErrorAction SilentlyContinue | ConvertFrom-Json
                    }
                    else {
                        $extensions = $null
                    }
                }
                else {
                    $extensions = $null
                }
                if($extensions)
                {
                    $extensions = $extensions.addons | where {$_.location -notin $excludeExtenionIDs}
                    foreach($ext in $extensions)
                    {
                        $extensionName = $ext.defaultLocale.Name
                        $extensionVersion = $ext.version
                        $extensionProfile = $profileInfo.Name
                        $extensionEnabled = $ext.active
                        # Convert InstallDate
                        $installTime = [Double]$ext.InstallDate
                        # Divide by 1,000 because we are going to add seconds on to the base date
                        $installTime = $installTime / 1000
                        $utcTime = Get-Date -Date "1970-01-01 00:00:00"
                        $utcTime = $utcTime.AddSeconds($installTime)
                        $localTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($utcTime, (Get-TimeZone))
                        $installDate = Get-Date $localTime -Format G
                        $extensionID = $ext.id.Replace("{","").Replace("}","")

                        [PSCustomObject]@{
                            Name = $extensionName
                            Version = $extensionVersion
                            Profile = $extensionProfile
                            Browser = "Mozilla Firefox"
                            Enabled = $extensionEnabled
                            InstallDate = $installDate
                            ID = $extensionID
                            User = $UserPath
                        }
                    }
                }
            }
        }
    }
}

function GetIniContent {
    param (
        $FilePath
    )

    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" #Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" #Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        }
        "(.+?)\s*=(.*)" #Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

### Variables
$ErrorActionPreference = 'SilentlyContinue'

### Gather user account names
$usernames = Get-ChildItem "C:\Users" -Directory -Exclude "*Public*","*Default*"

### Process each browser extension for each user and each browser
$allExtensions = foreach($username in $usernames)
{
    GetChromeExtensions -UserPath $username.FullName
    GetEdgeExtensions -UserPath $username.FullName
    GetFirefoxExtensions -UserPath $username.FullName
}

$result = New-Object System.Collections.ArrayList;
$i = 0

$allExtensions | ForEach-Object {
    $currentOutput = "" | Select-Object Name, Version, Profile, Browser, Enabled, InstallDate, ID, User, A1_Key;
    $currentOutput.Name = $_.Name;
    $currentOutput.Version = $_.Version;
    $currentOutput.Profile = $_.Profile;
    $currentOutput.Browser = $_.Browser;
    $currentOutput.Enabled = $_.Enabled;
    $currentOutput.InstallDate = $_.InstallDate;
    $currentOutput.ID = $_.ID;
    $currentOutput.User = $_.User;
    $currentOutput.A1_Key = $i;
    $result.Add($currentOutput) | Out-Null;
    $i++;
}

Write-Output $result