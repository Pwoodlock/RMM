# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logFile
    Write-Output $Message
}

# Function to check and install NuGet provider
function Ensure-NuGetProvider {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        try {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -Confirm:$false | Out-Null
            return "NuGet provider installed successfully."
        } catch {
            return "Failed to install NuGet provider. Error: $_"
        }
    }
    return "NuGet provider already installed."
}

# Function to check and install PSWindowsUpdate module
function Ensure-PSWindowsUpdate {
    if (-not (Get-Module -Name PSWindowsUpdate -ListAvailable)) {
        try {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -AllowClobber -Confirm:$false | Out-Null
            return "PSWindowsUpdate module installed successfully."
        } catch {
            return "Failed to install PSWindowsUpdate module. Error: $_"
        }
    }
    return "PSWindowsUpdate module already installed."
}

# Function to get the latest MSRT download URL
function Get-LatestMSRTUrl {
    $baseUrl = "https://www.microsoft.com/security/encyclopedia/adlpackages.aspx?package=msrt"
    try {
        $response = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing
        $content = $response.Content

        # Extract the download URL using regex
        $pattern = 'href="(https://go\.microsoft\.com/fwlink/\?LinkId=\d+)"'
        if ($content -match $pattern) {
            $downloadUrl = $matches[1]
            Log-Message "Latest MSRT URL found: $downloadUrl"
            return $downloadUrl
        } else {
            Log-Message "Failed to find MSRT download URL in the webpage content."
            return $null
        }
    } catch {
        Log-Message "Error fetching MSRT download URL: $_"
        return $null
    }
}

# Function to download and run MSRT
function Update-MSRT {
    $msrtUrl = Get-LatestMSRTUrl
    if (-not $msrtUrl) {
        Log-Message "Failed to get latest MSRT URL. Skipping MSRT update."
        return $false
    }

    $msrtPath = "$env:TEMP\MSRT.exe"
    
    try {
        Invoke-WebRequest -Uri $msrtUrl -OutFile $msrtPath
        Log-Message "MSRT downloaded successfully."
        
        $process = Start-Process -FilePath $msrtPath -ArgumentList "/Q" -PassThru -Wait
        if ($process.ExitCode -eq 0) {
            Log-Message "MSRT ran successfully."
        } else {
            Log-Message "MSRT execution failed with exit code: $($process.ExitCode)"
            return $false
        }
    } catch {
        Log-Message "Failed to download or run MSRT. Error: $_"
        return $false
    } finally {
        if (Test-Path $msrtPath) {
            Remove-Item $msrtPath -Force
        }
    }
    return $true
}

# Main script
$logFile = "C:\WindowsUpdates_Log.txt"
$overallStatus = "Success"

try {
    Log-Message "Script execution started."

    # Check and install NuGet provider
    $nugetResult = Ensure-NuGetProvider
    Log-Message $nugetResult
    if ($nugetResult -like "Failed*") {
        $overallStatus = "Failure"
    }

    # Check and install PSWindowsUpdate module
    $psUpdateResult = Ensure-PSWindowsUpdate
    Log-Message $psUpdateResult
    if ($psUpdateResult -like "Failed*") {
        $overallStatus = "Failure"
    }

    # Import the PSWindowsUpdate module
    Import-Module PSWindowsUpdate
    Log-Message "PSWindowsUpdate module imported."

    # Get all available updates
    $allUpdates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll

    # Filter for critical security updates
    $criticalUpdates = $allUpdates | Where-Object { $_.AutoSelectOnWebSites -and $_.MsrcSeverity -eq "Critical" }

    if ($criticalUpdates) {
        $installResult = $criticalUpdates | Install-WindowsUpdate -AcceptAll -IgnoreReboot -Confirm:$false
        Log-Message "Installed $($installResult.Count) critical security updates."
    } else {
        Log-Message "No critical security updates found."
    }

    # Filter for Windows Defender definition updates
    $defenderUpdates = $allUpdates | Where-Object { $_.Title -like "*Windows Defender*" -and $_.Categories -contains "Definition Updates" }

    if ($defenderUpdates) {
        $defenderResult = $defenderUpdates | Install-WindowsUpdate -AcceptAll -IgnoreReboot -Confirm:$false
        Log-Message "Installed $($defenderResult.Count) Windows Defender definition updates."
    } else {
        Log-Message "No Windows Defender definition updates found."
    }

    # Download and run MSRT
    $msrtResult = Update-MSRT
    if (-not $msrtResult) {
        $overallStatus = "Failure"
    }

    Log-Message "Script execution completed. Overall status: $overallStatus"
} catch {
    Log-Message "An error occurred: $_"
    $overallStatus = "Failure"
} finally {
    # This will be the last line output, which your RMM can use to determine success/failure
    Write-Output "RMMSYNC:$overallStatus"
}