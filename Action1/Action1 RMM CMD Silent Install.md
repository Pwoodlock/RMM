https://app.action1.com/agent/27789544-8871-11ee-8e03-0b13396710e4/Windows/agent(The_Forge_Mechanical_Engineering).msi

The above is for the Forge Mechanical engineering example.



If we already have access to the Command line interface of any type with administrator privileges then we can run this command below.

**Command line version**
```BASH
curl -L -o %TEMP%\agent.msi "https://app.action1.com/agent/28ac75e4-c731-11ee-badf-31fdeb67d3ca/Windows/agent(Albatel).msi" && msiexec /i %TEMP%\agent.msi /quiet
```





**Powershell Version**
```shell
Invoke-WebRequest -Uri "https://app.action1.com/agent/28ac75e4-c731-11ee-badf-31fdeb67d3ca/Windows/agent(Albatel).msi" -OutFile "$env:TEMP\agent.msi"; if ($?) { msiexec /i "$env:TEMP\agent.msi" /quiet }
```


PowerShell With MetaData


```
<#
.SYNOPSIS
Download and Install MSI Package.

.DESCRIPTION
This script downloads an MSI package from a specified URL using Invoke-WebRequest and then installs it quietly on the local system. The script checks if the download was successful before proceeding with the installation.

.EXAMPLE
.\InstallMSIPackage.ps1
Executes the script to download and install the MSI package from the predefined URL.

.PARAMETER Uri
The URL from which the MSI package will be downloaded. Default is set to "https://app.action1.com/agent/28ac75e4-c731-11ee-badf-31fdeb67d3ca/Windows/agent(Albatel).msi".

.PARAMETER OutFile
The output file path where the downloaded MSI will be saved. Default is "$env:TEMP\agent.msi".

.NOTES
This script requires PowerShell 3.0 or newer.
Make sure you have adequate permissions to install software on the system.
The script installs the MSI package quietly without user interaction.
Version: 1.2.0
Author: PowerShell Codex

.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/msiexec

#>

# Parameters
$Uri = "https://app.action1.com/agent/7f1a06e2-c74f-11ee-98e7-9b59c78987cf/Windows/agent(Migration).msi"
$OutFile = "$env:TEMP\agent.msi"

# Download the MSI package
Invoke-WebRequest -Uri $Uri -OutFile $OutFile

# Check if the download was successful
if ($?) {
    # Install the MSI package quietly
    msiexec /i $OutFile /quiet
} else {
    Write-Error "Download failed. Please check the URL and try again."
}

```