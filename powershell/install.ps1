Install-PackageProvider -Name NuGet -Force 
Install-Module PowerShellGet -AllowClobber -Force -SkipPublisherCheck
Update-Module -Name PowerShellGet -RequiredVersion 2.2.5

#set strong cryptography on 64 bit .Net Framework (version 4 and above)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
#set strong cryptography on 32 bit .Net Framework (version 4 and above).
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord

#check for supported security protocols.
 [Net.ServicePointManager]::SecurityProtocol

Install-Module PowershellGet -Force