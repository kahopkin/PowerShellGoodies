﻿Function ConvertFrom-SecureString-AsPlainText{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.Security.SecureString]
        $SecureString
    )
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);
    $PlainTextString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
    $PlainTextString;
}