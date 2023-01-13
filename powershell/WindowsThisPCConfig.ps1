#WindowsThisPCConfig


# from
# https://superuser.com/questions/840790/how-can-i-create-a-new-system-folder-to-show-up-in-this-pc-in-windows-8-1-with/914701#914701
# ##############################################################################
# Configuration
# ##############################################################################
$FolderName="Python"
$FolderLocation="%USERPROFILE%\Python"
$FolderHint="Python scripts"
$FolderIcon="C:\Python37\pythonw.exe,0"

# ##############################################################################
# Variables
# ##############################################################################
$MYCLSID=$([guid]::NewGuid().ToString("B").ToUpper())
$HKCU_CLSID="HKCU:\Software\Classes\CLSID\$MYCLSID"

# ##############################################################################
# 32bit
# ##############################################################################
New-Item -Path $HKCU_CLSID
Set-ItemProperty -Path $HKCU_CLSID -Name "(Default)" -Value $FolderName
Set-ItemProperty -Path $HKCU_CLSID -Name "InfoTip" -Value $FolderHint
Set-ItemProperty -Path $HKCU_CLSID -Name "DescriptionID" -Value 3 -type dword
Set-ItemProperty -Path $HKCU_CLSID -Name "System.IsPinnedtoNameSpaceTree" -Value 1 -Type DWORD

New-Item -Path $HKCU_CLSID\DefaultIcon
Set-ItemProperty -Path $HKCU_CLSID\DefaultIcon -Name "(Default)" -Value $FolderIcon

New-Item -Path $HKCU_CLSID\InProcServer32
Set-ItemProperty -Path $HKCU_CLSID\InProcServer32 -Name "(Default)" -Value "shdocvw.dll"
Set-ItemProperty -Path $HKCU_CLSID\InProcServer32 -Name "ThreadingModel" -Value "Both"

New-Item -Path $HKCU_CLSID\Instance
Set-ItemProperty -Path $HKCU_CLSID\Instance -Name "CLSID" -Value "{0afaced1-e828-11d1-9187-b532f1e9575d}"

New-Item -Path $HKCU_CLSID\Instance\InitPropertyBag
Set-ItemProperty -Path $HKCU_CLSID\Instance\InitPropertyBag -Name "Attributes" -Value 15 -Type DWORD
Set-ItemProperty -Path $HKCU_CLSID\Instance\InitPropertyBag -Name "Target" -Value $FolderLocation -Type ExpandString

New-Item -Path $HKCU_CLSID\ShellEx
New-Item -Path $HKCU_CLSID\ShellEx\PropertySheetHandlers
New-Item -Path "$HKCU_CLSID\ShellEx\PropertySheetHandlers\tab 1 general"
Set-ItemProperty -Path "$HKCU_CLSID\ShellEx\PropertySheetHandlers\tab 1 general" -Name "(Default)" -Value "{21b22460-3aea-1069-a2dc-08002b30309d}"
New-Item -Path "$HKCU_CLSID\ShellEx\PropertySheetHandlers\tab 2 customize"
Set-ItemProperty -Path "$HKCU_CLSID\ShellEx\PropertySheetHandlers\tab 2 customize" -Name "(Default)" -Value "{ef43ecfe-2ab9-4632-bf21-58909dd177f0}"
New-Item -Path "$HKCU_CLSID\ShellEx\PropertySheetHandlers\tab 3 sharing"
Set-ItemProperty -Path "$HKCU_CLSID\ShellEx\PropertySheetHandlers\tab 3 sharing" -Name "(Default)" -Value "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}"
New-Item -Path "$HKCU_CLSID\ShellEx\PropertySheetHandlers\tab 4 security"
Set-ItemProperty -Path "$HKCU_CLSID\ShellEx\PropertySheetHandlers\tab 4 security" -Name "(Default)" -Value "{1f2e5c40-9550-11ce-99d2-00aa006e086c}"

New-Item -Path $HKCU_CLSID\ShellFolder
Set-ItemProperty -Path $HKCU_CLSID\ShellFolder -Name "Attributes" -Value 0xf080004d -type DWORD
Set-ItemProperty -Path $HKCU_CLSID\ShellFolder -Name "WantsFORPARSING" -Value ""
Set-ItemProperty -Path $HKCU_CLSID\ShellFolder -Name "HideAsDeletePerUser" -Value ""

# ##############################################################################
# 64bit
# ##############################################################################
if ([Environment]::Is64BitsOperatingSystem) {
    $HKCU_WOW6432Node_CLSID="HKCU:\Software\Classes\WOW6432Node\CLSID\$MYCLSID"

    New-Item -Path $HKCU_WOW6432Node_CLSID
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID -Name "(Default)" -Value $FolderName
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID -Name "InfoTip" -Value $FolderHint
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID -Name "DescriptionID" -Value 3 -type dword
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID -Name "System.IsPinnedtoNameSpaceTree" -Value 1 -Type DWORD

    New-Item -Path $HKCU_WOW6432Node_CLSID\DefaultIcon
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\DefaultIcon -Name "(Default)" -Value $FolderIcon

    New-Item -Path $HKCU_WOW6432Node_CLSID\InProcServer32
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\InProcServer32 -Name "(Default)" -Value "shdocvw.dll"
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\InProcServer32 -Name "ThreadingModel" -Value "Both"

    New-Item -Path $HKCU_WOW6432Node_CLSID\Instance
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\Instance -Name "CLSID" -Value "{0afaced1-e828-11d1-9187-b532f1e9575d}"

    New-Item -Path $HKCU_WOW6432Node_CLSID\Instance\InitPropertyBag
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\Instance\InitPropertyBag -Name "Attributes" -Value 15 -Type DWORD
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\Instance\InitPropertyBag -Name "Target" -Value $FolderLocation -Type ExpandString

    New-Item -Path $HKCU_WOW6432Node_CLSID\ShellEx
    New-Item -Path $HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers
    New-Item -Path "$HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers\tab 1 general"
    Set-ItemProperty -Path "$HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers\tab 1 general" -Name "(Default)" -Value "{21b22460-3aea-1069-a2dc-08002b30309d}"
    New-Item -Path "$HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers\tab 2 customize"
    Set-ItemProperty -Path "$HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers\tab 2 customize" -Name "(Default)" -Value "{ef43ecfe-2ab9-4632-bf21-58909dd177f0}"
    New-Item -Path "$HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers\tab 3 sharing"
    Set-ItemProperty -Path "$HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers\tab 3 sharing" -Name "(Default)" -Value "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}"
    New-Item -Path "$HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers\tab 4 security"
    Set-ItemProperty -Path "$HKCU_WOW6432Node_CLSID\ShellEx\PropertySheetHandlers\tab 4 security" -Name "(Default)" -Value "{1f2e5c40-9550-11ce-99d2-00aa006e086c}"

    New-Item -Path $HKCU_WOW6432Node_CLSID\ShellFolder
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\ShellFolder -Name "Attributes" -Value 0xf080004d -type DWORD
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\ShellFolder -Name "WantsFORPARSING" -Value ""
    Set-ItemProperty -Path $HKCU_WOW6432Node_CLSID\ShellFolder -Name "HideAsDeletePerUser" -Value ""
}

# ##############################################################################
# Add to explorer
# ##############################################################################
New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer -ErrorAction SilentlyContinue
New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace -ErrorAction SilentlyContinue
New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\$MYCLSID

# ##############################################################################
# Restart explorer
# ##############################################################################
Stop-Process -ProcessName explorer
