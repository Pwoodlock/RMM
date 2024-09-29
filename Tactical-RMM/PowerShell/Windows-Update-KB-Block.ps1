
#  Script to Stop / Hide a certain KB Update on the system.  Note that this will only block the version specified, if there's an Update after this for the driver /update it will bypass and install.
#  This was created for a issue with a Roland Plotter for CGL that works through USB in which KB5039212 broke USB print que's etc.
#  
#  First try Local Group Policy.
#  Any questions Email patrick@rockfieldit.com
#  24-06-2024

Install-Module PSWindowsUpdate
Set-ExecutionPolicy RemoteSigned
Get-WindowsUpdate
Hide-WindowsUpdate -KBArticleID KB5039212
