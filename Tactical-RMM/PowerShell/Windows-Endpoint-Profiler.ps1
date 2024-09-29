# Get Computer Name
$ComputerName = $env:COMPUTERNAME

# Get IP Addresses of all interfaces
$IPAddresses = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' } | Select-Object InterfaceAlias, IPAddress

# Get Currently Logged in User
$LoggedInUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName

# Check if the computer is AD joined
$ADJoined = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain

# Check if the computer is Entra (Azure AD) joined
$EntraJoined = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo\*" -ErrorAction SilentlyContinue

# Get Antivirus Information
$AntiVirus = Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Select-Object displayName

# Get Last Reboot Time
$LastReboot = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# Get CPU Information
$CPU = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
$CPUUsage = (Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average

# Get RAM Information
$RAM = Get-WmiObject -Class Win32_OperatingSystem
$RAMTotal = [math]::Round($RAM.TotalVisibleMemorySize / 1MB, 2)
$RAMFree = [math]::Round($RAM.FreePhysicalMemory / 1MB, 2)
$RAMUsedPercent = [math]::Round(($RAMTotal - $RAMFree) / $RAMTotal * 100, 2)

# Get Hard Drive Information
$Drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

# Check Windows 11 and Office Work Compatibility
$Win11Compatible = $true
$OfficeWorkCompatible = $true
$CompatibilityChecks = @()

# Improved CPU Check
$CPUCheck = $false
$CPUName = $CPU.Name

if ($CPUName -match 'Intel') {
    # Check for Intel processors
    if ($CPUName -match 'i[3-9]|Xeon') {
        $Generation = if ($CPUName -match '(\d+)(?:th|st|nd|rd)?\s+Gen') { 
            [int]$matches[1] 
        } elseif ($CPUName -match 'i[3-9]-(\d{4,5})') {
            [int]($matches[1][0])
        } else { 0 }
        
        $CPUCheck = $Generation -ge 8
    }
} elseif ($CPUName -match 'AMD') {
    # Check for AMD processors
    if ($CPUName -match 'Ryzen') {
        $Generation = if ($CPUName -match 'Ryzen\s+(\d)') { [int]$matches[1] } else { 0 }
        $CPUCheck = $Generation -ge 3  # Ryzen 3000 series and above are generally compatible
    } elseif ($CPUName -match 'Epyc') {
        $CPUCheck = $true  # All Epyc processors should be compatible
    }
}

# Fallback check if we couldn't determine the generation
if (-not $CPUCheck) {
    $CPUCheck = $CPU.NumberOfCores -ge 2 -and $CPU.MaxClockSpeed -ge 1000
}

$CompatibilityChecks += "CPU (Intel 8th Gen+ or AMD Ryzen 3000+): $(if($CPUCheck){'Pass'}else{'Fail'}) - $CPUName"
$Win11Compatible = $Win11Compatible -and $CPUCheck
$OfficeWorkCompatible = $OfficeWorkCompatible -and $CPUCheck

# Check RAM
$RAMCheck = $RAMTotal -ge 4
$RAMOfficeCheck = $RAMTotal -ge 16
$CompatibilityChecks += "RAM for Windows 11 (4GB+): $(if($RAMCheck){'Pass'}else{'Fail'})"
$CompatibilityChecks += "RAM for Office Work (16GB+): $(if($RAMOfficeCheck){'Pass'}else{'Fail'})"
$Win11Compatible = $Win11Compatible -and $RAMCheck
$OfficeWorkCompatible = $OfficeWorkCompatible -and $RAMOfficeCheck

# Check Storage
$StorageCheck = ($Drives | Where-Object { $_.DeviceID -eq 'C:' }).Size -ge 64GB
$CompatibilityChecks += "Storage (64GB+): $(if($StorageCheck){'Pass'}else{'Fail'})"
$Win11Compatible = $Win11Compatible -and $StorageCheck
$OfficeWorkCompatible = $OfficeWorkCompatible -and $StorageCheck

# Check TPM
$TPM = Get-Tpm -ErrorAction SilentlyContinue
$TPMCheck = $TPM.TpmPresent -and $TPM.TpmReady
$CompatibilityChecks += "TPM 2.0: $(if($TPMCheck){'Present'}else{'Not detected'})"
$Win11Compatible = $Win11Compatible -and $TPMCheck
$OfficeWorkCompatible = $OfficeWorkCompatible -and $TPMCheck

# Output the information
Write-Output "Computer Name: $ComputerName"

Write-Output "`nIP Addresses:"
$IPAddresses | ForEach-Object {
    Write-Output "Interface: $($_.InterfaceAlias), IP: $($_.IPAddress)"
}

Write-Output "`nCurrently Logged in User: $LoggedInUser"
Write-Output "AD Joined: $ADJoined"
Write-Output "Entra (Azure AD) Joined: $(if ($EntraJoined) { 'Yes' } else { 'No' })"

Write-Output "`nAntivirus:"
if ($AntiVirus) {
    $AntiVirus | ForEach-Object {
        Write-Output $_.displayName
    }
} else {
    Write-Output "No antivirus detected"
}

Write-Output "`nLast Reboot: $LastReboot"

Write-Output "`nCPU Information:"
Write-Output "Name: $CPUName"
Write-Output "Usage: $CPUUsage%"
Write-Output "Cores: $($CPU.NumberOfCores)"
Write-Output "Max Clock Speed: $($CPU.MaxClockSpeed) MHz"

Write-Output "`nRAM Information:"
Write-Output "Total RAM: $RAMTotal GB"
Write-Output "Free RAM: $RAMFree GB"
Write-Output "RAM Usage: $RAMUsedPercent%"

Write-Output "`nHard Drive Information:"
foreach ($Drive in $Drives) {
    $Size = [math]::Round($Drive.Size / 1GB, 2)
    $FreeSpace = [math]::Round($Drive.FreeSpace / 1GB, 2)
    $UsedPercent = [math]::Round(($Size - $FreeSpace) / $Size * 100, 2)
    Write-Output "Drive $($Drive.DeviceID)"
    Write-Output "  Total Size: $Size GB"
    Write-Output "  Free Space: $FreeSpace GB"
    Write-Output "  Used Space: $UsedPercent%"
}

Write-Output "`nWindows 11 and Office Work Compatibility Check:"
Write-Output "Windows 11 Hardware Compatibility: $(if($Win11Compatible){'Compatible'}else{'Not Compatible'})"
Write-Output "Office Work Compatibility: $(if($OfficeWorkCompatible){'Compatible'}else{'Not Compatible'})"
$CompatibilityChecks | ForEach-Object { Write-Output "  $_" }

Write-Output "`nNote: This script checks basic hardware compatibility for Windows 11 and office work suitability."
Write-Output "It does not check all possible requirements or exceptions."
Write-Output "For the most accurate results, use Microsoft's official compatibility check tool."