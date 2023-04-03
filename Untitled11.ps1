Get-AzureStorageAccount -StorageAccountName $storageName `
    -ErrorAction SilentlyContinue `
    -WarningAction SilentlyContinue `
    -Verbose:$false

New-AzureStorageAccount -StorageAccountName $storageName -Location $storageLocation -ErrorAction Stop -WarningAction SilentlyContinue -verbose:$false