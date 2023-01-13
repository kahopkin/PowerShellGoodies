#AddLocationToPSModulePath

$env:PSModulePath

C:\Users\kahopkin\OneDrive - Microsoft\Documents\WindowsPowerShell\Modules;

C:\Program Files\WindowsPowerShell\Modules;C:\windows\system32\WindowsPowerShell\v1.0\Modules;C:\Program Files (x86)\Microsoft Azure Information Protection\Powershell

#change the value of the PSModulePath environment variable.
$envPaths ="C:\Program Files\WindowsPowerShell\Modules;C:\windows\system32\WindowsPowerShell\v1.0\Modules;C:\Program Files (x86)\Microsoft Azure Information Protection\Powershell"

$Env:PSModulePath = "C:\Program Files\WindowsPowerShell\Modules;C:\windows\system32\WindowsPowerShell\v1.0\Modules;C:\Program Files (x86)\Microsoft Azure Information Protection\Powershell"

#to add location
#$Env:PSModulePath = $Env:PSModulePath+";C:\Program Files\Fabrikam\Modules"


# You can verify the location of your Documents folder using the following command: 
[Environment]::GetFolderPath('MyDocuments')

<#
adds the C:\Program Files\Fabrikam\Modules path to the value of the 
PSModulePath environment variable without expanding the un-expanded strings.
#>

$key = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager').OpenSubKey('Environment', $true)
$path = $key.GetValue('PSModulePath','','DoNotExpandEnvironmentNames')
$path += ';C:\Program Files\Fabrikam\Modules' # or '%ProgramFiles%\Fabrikam\Modules'
$key.SetValue('PSModulePath',$path,[Microsoft.Win32.RegistryValueKind]::ExpandString)


<#
To add a path to the user setting, change the registry provider from HKLM:\ to HKCU:\.
#>
$key = (Get-Item 'HKCU:\SYSTEM\CurrentControlSet\Control\Session Manager').OpenSubKey('Environment', $true)
$path = $key.GetValue('PSModulePath','','DoNotExpandEnvironmentNames')
$path += ';C:\Program Files\Fabrikam\Modules' # or '%ProgramFiles%\Fabrikam\Modules'
$key.SetValue('PSModulePath',$path,[Microsoft.Win32.RegistryValueKind]::ExpandString)