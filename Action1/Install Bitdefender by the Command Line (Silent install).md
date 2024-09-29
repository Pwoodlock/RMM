Revision #1

  

**This information is how to install the Bitdefender Endpoint Client on a clients machine through the command line.**  

This can be done via the "Run Command" in ScreenConnect portal of the users Machine.

  
  

***Prerequisites***

  

 - MSI remote installer hosted on Rockfield's Website. ([https://rockfieldit.com/files/BEST_downloaderWrapper.msi)](https://rockfieldit.com/files/BEST_downloaderWrapper.msi))

 - Companies ID Hash (Base64) (GravityZone under the company)

 - Remote access of some form to execute the CMD Command.

  
  

`msiexec /i C:\My Downloads\BEST_downloaderWrapper.msi /qn GZ_PACKAGE_ID=aHR0cH-bGFuZz1lbi1VUw== REBOOT_IF_NEEDED=1`

  

Where:

  

-   The installation package name is :  `setupdownloader_[aHR0cH-bGFuZz1lbi1VUw==].exe`

-   The  `GZ_PACKAGE_ID`  value is:  `aHR0cH-bGFuZz1lbi1VUw==`.

    This is same string that is part of the downloader name.

  

So in theory, we can then use this command when we have access to the CMD through ScreenConnect

  

So the the final command to execute is as follows:

  

curl -o "%TEMP%\BEST_downloaderWrapper.msi" "

https://rockfieldit.com/files/BEST_downloaderWrapper.msi" && msiexec /i "%TEMP%\BEST_downloaderWrapper.msi" /qn GZ_PACKAGE_ID=aHR0cHM6Ly9jbG91ZGd6LWVjcy5ncmF2aXR5em9uZS5iaXRkZWZlbmRlci5jb20vUGFja2FnZXMvQlNUV0lOLzAvZXcyc19BL2luc3RhbGlleci54bWw-bGFuZz1lbi1VUw== REBOOT_IF_NEEDED=0 && del "%TEMP%\BEST_downloaderWrapper.msi"

  

**As you can see the above highlighted string is the company id that we got from when we made the installer.**

  

  

```C++
curl -o "%TEMP%\BEST_downloaderWrapper.msi" "https://rockfieldit.com/files/BEST_downloaderWrapper.msi" && ^
msiexec /i "%TEMP%\BEST_downloaderWrapper.msi" /qn GZ_PACKAGE_ID=INSERT_COMPANY_INSTALLER_HASH_HERE== REBOOT_IF_NEEDED=0 && ^
del "%TEMP%\BEST_downloaderWrapper.msi"

```

  

**Use the Link above but replace the company hash!!**


> [!NOTE]
> POWERSHELL VERSION


---



```C++
Invoke-WebRequest -Uri "https://rockfieldit.com/files/BEST_downloaderWrapper.msi" -OutFile "$env:TEMP\BEST_downloaderWrapper.msi"; Start-Process 'msiexec.exe' -ArgumentList '/i', "$env:TEMP\BEST_downloaderWrapper.msi", '/qn', 'GZ_PACKAGE_ID=aHR0cHM6Ly9jbG91ZGd6LWVjcy5ncmF2aXR5em9uZS5iaXRkZWZlbmRlci5jb20vUGFja2FnZXMvQlNUV0lOLzAvZXcyc19BL2luc3RhbGlleci54bWw-bGFuZz1lbi1VUw==', 'REBOOT_IF_NEEDED=0' -Wait -NoNewWindow; Remove-Item "$env:TEMP\BEST_downloaderWrapper.msi"

```




```bash
curl -o "%TEMP%\BEST_downloaderWrapper.msi" "https://rockfieldit.com/files/BEST_downloaderWrapper.msi" && msiexec /i "%TEMP%\BEST_downloaderWrapper.msi" /qn /l*v "%TEMP%\BEST_install.log" GZ_PACKAGE_ID=aHR0cHM6Ly9jbG91ZGd6LWVjcy5ncmF2aXR5em9uZS5iaXRkZWZlbmRlci5jb20vUGFja2FnZXMvQlNUV0lOLzAvZXcyc19BL2luc3RhbGlleCIubWw-bGFuZz1lbi1VUw== REBOOT_IF_NEEDED=0 && del "%TEMP%\BEST_downloaderWrapper.msi"
```
