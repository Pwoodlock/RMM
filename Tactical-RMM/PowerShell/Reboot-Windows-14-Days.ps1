# Automated PowerShell script for prompting user to reboot if the machine has been online for more than 14 days
# Enforces reboot after 3 snoozes
# Last updated: July 29, 2024

# Configuration
$uptimeThresholdInDays = 0.001  # Set back to 14 days for production use
$rockfieldPath = "C:\Program Files\Rockfield"
$logFolder = Join-Path $rockfieldPath "logs\tactical"
$logFile = Join-Path $logFolder "reboot_log.txt"
$snoozeCountFile = Join-Path $logFolder "snooze_count.txt"
$maxSnoozes = 1

# Ensure Rockfield folder and log folder exist
if (!(Test-Path $rockfieldPath)) {
    New-Item -Path $rockfieldPath -ItemType Directory -Force | Out-Null
}
if (!(Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
}

# Function to log messages
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
    Write-Output $message  # Also output to console for immediate feedback
}

# Function to get current snooze count
function Get-SnoozeCount {
    if (Test-Path $snoozeCountFile) {
        $count = Get-Content $snoozeCountFile -Raw
        if ([int]::TryParse($count, [ref]$null)) {
            return [int]$count
        }
    }
    return 0
}

# Function to update snooze count
function Update-SnoozeCount {
    param([int]$count)
    $count | Out-File $snoozeCountFile -Force
    Write-Log "Snooze count updated to $count"
}

# Get the system uptime
$uptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
$uptime = (Get-Date) - $uptime
$uptimeInDays = $uptime.TotalDays

Write-Log "Script started. Current uptime: $uptimeInDays days"

# Check if the uptime is greater than or equal to the threshold
if ($uptimeInDays -lt $uptimeThresholdInDays) {
    Write-Log "Computer was restarted $uptimeInDays days ago. No action needed."
    # Reset snooze count if uptime is less than threshold
    if (Test-Path $snoozeCountFile) {
        Remove-Item $snoozeCountFile -Force
        Write-Log "Snooze count reset."
    }
    exit 0
}

# Get current snooze count
$snoozeCount = Get-SnoozeCount
Write-Log "Current snooze count: $snoozeCount"

# Only proceed if uptime threshold is exceeded and snooze limit not reached
if ($uptimeInDays -ge $uptimeThresholdInDays -and $snoozeCount -lt $maxSnoozes) {
    Write-Log "Uptime threshold exceeded. Preparing to show notification."

    # Ensure required modules are installed
    $modules = @("BurntToast", "RunAsUser")
    foreach ($module in $modules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Write-Log "Installing $module module"
            try {
                Install-Module -Name $module -Force -AllowClobber -ErrorAction Stop
            } catch {
                Write-Log "Failed to install $module module: $_"
                exit 1
            }
        }
        Import-Module $module -ErrorAction Stop
    }

    # Create ToastReboot protocol handler if it doesn't exist
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
    $ProtocolHandler = Get-Item 'HKCR:\ToastReboot' -ErrorAction SilentlyContinue
    if (!$ProtocolHandler) {
        Write-Log "Creating ToastReboot protocol handler"
        New-Item 'HKCR:\ToastReboot' -Force
        Set-ItemProperty 'HKCR:\ToastReboot' -Name '(DEFAULT)' -Value 'url:ToastReboot' -Force
        Set-ItemProperty 'HKCR:\ToastReboot' -Name 'URL Protocol' -Value '' -Force
        New-ItemProperty -Path 'HKCR:\ToastReboot' -PropertyType DWord -Name 'EditFlags' -Value 2162688
        New-Item 'HKCR:\ToastReboot\Shell\Open\command' -Force
        Set-ItemProperty 'HKCR:\ToastReboot\Shell\Open\command' -Name '(DEFAULT)' -Value 'C:\Windows\System32\shutdown.exe -r -t 300' -Force
    }

# Show toast notification
try {
    Write-Log "Attempting to show toast notification"
    
    # Set environment variables to pass data to the scriptblock
    [System.Environment]::SetEnvironmentVariable('SNOOZE_COUNT', $snoozeCount, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('MAX_SNOOZES', $maxSnoozes, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('SNOOZE_COUNT_FILE', $snoozeCountFile, [System.EnvironmentVariableTarget]::Process)
    
    $result = Invoke-AsCurrentUser -ScriptBlock {
        $snoozeCount = [int]$env:SNOOZE_COUNT
        $maxSnoozes = [int]$env:MAX_SNOOZES
        $snoozeCountFile = $env:SNOOZE_COUNT_FILE
        
        $Text1 = New-BTText -Content "Message from Rockfield IT Services"
        
        $mainMessage = "Your computer needs to be rebooted to apply important security updates, improve system health, and update software. Please save all your work before rebooting."
        
        switch ($snoozeCount) {
            0 { $additionalMessage = "You can snooze this message up to 3 times." }
            1 { $additionalMessage = "This is your second reminder. Please save your work and reboot soon." }
            2 { $additionalMessage = "This is your final reminder. If snoozed, your machine will automatically reboot in 15 minutes. Please save all your work immediately." }
        }
        
        $Text2 = New-BTText -Content "$mainMessage`n`n$additionalMessage"
        
        $contactInfo = "For assistance, contact IT:`nEmail: help@rf.ie`nPhone: 059 91 58008"
        $Text3 = New-BTText -Content $contactInfo
        
        $Button = New-BTButton -Content "Snooze" -Snooze -Id 'SnoozeTime'
        $Button2 = New-BTButton -Content "Reboot now" -Arguments "ToastReboot:" -ActivationType Protocol
        $5Min = New-BTSelectionBoxItem -Id 5 -Content '5 minutes'
        $10Min = New-BTSelectionBoxItem -Id 10 -Content '10 minutes'
        $1Hour = New-BTSelectionBoxItem -Id 60 -Content '1 hour'
        $Items = $5Min, $10Min, $1Hour
        $SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items $Items
        $Action = New-BTAction -Buttons $Button, $Button2 -Inputs $SelectionBox
        
        $Binding = New-BTBinding -Children $Text1, $Text2, $Text3
        $Visual = New-BTVisual -BindingGeneric $Binding
        $Content = New-BTContent -Visual $Visual -Actions $Action
        
        $toast = Submit-BTNotification -Content $Content
        
        # Only increment snooze count if user actively snoozed
        $newSnoozeCount = $snoozeCount
        if ($toast.Activated -eq 'SnoozeActivated') {
            $newSnoozeCount++
            $newSnoozeCount | Out-File $snoozeCountFile -Force
        }
        
        return @{
            ToastResult = $toast | ConvertTo-Json -Compress
            NewSnoozeCount = $newSnoozeCount
            UserAction = $toast.Activated
        }
    }

    Write-Log "Toast notification shown successfully"
    Write-Log "Toast result: $($result.ToastResult)"
    Write-Log "New snooze count: $($result.NewSnoozeCount)"
    Write-Log "User action: $($result.UserAction)"

    # Update snooze count if changed due to user action
    if ($result.NewSnoozeCount -ne $snoozeCount) {
        Update-SnoozeCount $result.NewSnoozeCount
    }
    
    # Schedule forced reboot only if user actively snoozed and it was the third snooze
    if ($result.UserAction -eq 'SnoozeActivated' -and $result.NewSnoozeCount -ge $maxSnoozes) {
        Write-Log "Max snoozes reached after user interaction. Scheduling forced reboot in 15 minutes."
        Start-Process -FilePath "shutdown.exe" -ArgumentList "/r /t 900 /c ""Your computer will restart in 15 minutes to apply important updates. Please save your work immediately.""" -NoNewWindow
    }
    } catch {
    Write-Log "Failed to show toast notification: $_"
    Write-Log "Error details: $($_.Exception.Message)"
    Write-Log "Stack trace: $($_.ScriptStackTrace)"
    }
} elseif ($snoozeCount -ge $maxSnoozes) {
    Write-Log "Max snoozes already reached. No further action needed."
} else {
    Write-Log "No action needed. Uptime: $uptimeInDays days, Snooze count: $snoozeCount"
}

Write-Log "Script completed"