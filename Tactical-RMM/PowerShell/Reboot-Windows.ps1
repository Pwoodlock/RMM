# Reboot script for Windows machines

# Optional: Add a delay before reboot (in seconds)
$delay = 300

# Optional: Display a message to the user
$message = "Your computer has successfully been updated & will restart in $delay seconds. Please save your work now and reboot !"

# Display the message (if using)
if ($message) {
    Write-Output $message
}

# Schedule the reboot
shutdown.exe /r /t $delay /c $message

Write-Output "Reboot scheduled."