@echo off

REM Setup deployment URL
set "DeploymentURL="Insert your API Link here from the Deployment panel" 

set "Name="
for /f "usebackq tokens=* delims=" %%# in (
    `wmic service where "name like 'tacticalrmm'" get Name /Format:Value`
) do (
    for /f "tokens=* delims=" %%g in ("%%#") do set "%%g"
)

if not defined Name (
    echo Tactical RMM not found, installing now.
    if not exist c:\ProgramData\TacticalRMM\temp md c:\ProgramData\TacticalRMM\temp
    powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted
    powershell Add-MpPreference -ExclusionPath "C:\Program Files\TacticalAgent\*"
    powershell Add-MpPreference -ExclusionPath "C:\Program Files\Mesh Agent\*"
    powershell Add-MpPreference -ExclusionPath C:\ProgramData\TacticalRMM\*
    cd c:\ProgramData\TacticalRMM\temp
    powershell Invoke-WebRequest "%DeploymentURL%" -Outfile tactical.exe
    REM"C:\Program Files\TacticalAgent\unins000.exe" /VERYSILENT
    tactical.exe
    rem exit /b 1
) else (
    echo Tactical RMM already installed Exiting
Exit 0
)