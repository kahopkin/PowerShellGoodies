﻿#from datacenter201
#ExtractZips

#& "$PSScriptRoot\UtilityFunctions.ps1"

Function global:CreateEnvironmentFiles
{
    Param(
       [Parameter(Mandatory = $false)] [String] $RootFolder    
      ,[Parameter(Mandatory = $true)]  [String] $TemplateDir
      ,[Parameter(Mandatory = $true)]  [Object] $DeployObject
      ,[Parameter(Mandatory = $true)]  [Object] $Cloud
      ,[Parameter(Mandatory = $true)]  [Object] $DeploymentOutput

    )
    <#
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Yellow "[$today] START CreateEnvironmentFiles:" $RootFolder
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Green "PARAMETERS:"
    Write-Host -ForegroundColor Green "`$RootFolder=`"$RootFolder`""
    Write-Host -ForegroundColor Green "`$TemplateDir=`"$TemplateDir`""
    Write-Host -ForegroundColor Green "================================================================================"
    #Write-Host -ForegroundColor Green "FileList.Count: " $FileList.Count
    #Write-Host -ForegroundColor Green "FileList:" 
    #>

    <#
    $Caller='CreateEnvironmentFiles[25] DeployObject::'
    PrintDeployObject -object $DeployObject -Caller $Caller
    #>
    $DeploymentName = $DeployObject.DeploymentName
    #Write-Host -ForegroundColor Yellow "CreateEnvironmentFiles[26] `$DeploymentName=`"$DeploymentName`""
    If($DeploymentOutput -eq $null){
        $DeploymentOutput = Get-AzDeployment -DeploymentName $DeploymentName    
    }
    #Write-Host -ForegroundColor Yellow "CreateEnvironmentFiles[38] DeploymentOutput.Outputs.storageAccountNameMain=" $DeploymentOutput.Outputs.storageAccountNameMain.Value
    $EnvFolder = $null
    $EnvFilePath = $null

    $DPPEnvObject = [ordered]@{
        GENERATE_SOURCEMAP = "$false";
        REACT_APP_AAD_CLIENT_ID = $DeployObject.ClientAppRegAppId;
        REACT_APP_AAD_AUTHORITY = $DeployInfo.Cloud.ActiveDirectoryAuthority;
        REACT_APP_AAD_REDIRECT_URI = "https://" + $DeployObject.ClientAppRegName + ".azurewebsites.us";
        REACT_APP_LOGIN_SCOPES = "array:User.Read";
        REACT_APP_GRAPH_ENDPOINT = $DeployInfo.Cloud.GraphUrl + "v1.0/me";
        REACT_APP_GRAPH_SCOPES = "array:User.Read"
        REACT_APP_DPP_API_ENDPOINT = "https://" + $DeployObject.APIAppRegName + ".azurewebsites.us/api";
        REACT_APP_DPP_API_SCOPES = "array:api://" + $DeployObject.APIAppRegAppId + "/.default" ;
        REACT_APP_COMPLETED_TRANFERS_POLLING_INTERVAL_MS=10000
    }#DPPEnvObject

    $DPPLocalEnvObject = [ordered]@{
        REACT_APP_DPP_API_ENDPOINT = "http://localhost:7047/api";
        REACT_APP_AAD_REDIRECT_URI = "http://localhost:3000";
    }#DPPLocalEnvObject

    $DTPEnvObject = [ordered]@{
        GENERATE_SOURCEMAP = "$false";
        REACT_APP_AAD_CLIENT_ID = $DeployObject.ClientAppRegAppId;
        REACT_APP_AAD_AUTHORITY = $DeployInfo.Cloud.ActiveDirectoryAuthority;
        REACT_APP_AAD_REDIRECT_URI = "https://" + $DeployObject.ClientAppRegName + ".azurewebsites.us";
        REACT_APP_LOGIN_SCOPES = "array:User.Read";
        REACT_APP_GRAPH_ENDPOINT = $DeployInfo.Cloud.GraphUrl + "/v1.0/me";
        REACT_APP_GRAPH_SCOPES = "array:User.Read";
        REACT_APP_DTP_API_ENDPOINT = "https://" + $DeployObject.APIAppRegName + ".azurewebsites.us/api" ;
        REACT_APP_DTP_API_SCOPES = "array:api://" + $DeployObject.APIAppRegAppId + "/.default" ;
        REACT_APP_TRANSFER_HISTORY_POLLING_INTERVAL_MS = 10000
        REACT_APP_DEFAULT_DATE_FORMAT = "MM/DD/YYYY HH:mm:ss"
        REACT_APP_DTS_AZ_STORAGE_URL = "https://" + $DeploymentOutput.Outputs.storageAccountNameMain.Value + ".blob." + $DeployInfo.Cloud.StorageEndpointSuffix + "/"
        REACT_APP_HELP_URL="https://app-docfx.azurewebsites.us"
    }#DTPEnvObject
    
    $DTPLocalEnvObject = [ordered]@{
        #REACT_APP_DTP_API_ENDPOINT=http://localhost:7071/api
        # REACT_APP_AAD_REDIRECT_URI: Redirect Uri for Azure AD
        REACT_APP_AAD_REDIRECT_URI = "http://localhost:3000"

    }#DTPLocalEnvObject

    if (Test-Path $TemplateDir) 
    {        
        $FileListJson = ConvertTo-Json (Get-ChildItem -Path $TemplateDir | Select FullName).FullName
        $FileList = $FileListJson | Out-String | ConvertFrom-Json
        #Write-Host -ForegroundColor Magenta "[65] Directory=$TemplateDir"
        #Write-Host -ForegroundColor Green "[66] Folder/FileList:"     
        $type = $FileList.GetType() 
        #System.Object
        If( $type.BaseType.FullName -eq "System.Object" )
        {
            #Write-Host -ForegroundColor Yellow "[71] type.BaseType.FullName:" $type.BaseType.FullName
            #Write-Host -ForegroundColor Yellow "[72] FileList:" $FileList
            $Path = (Get-ItemProperty  $FileList | select FullName).FullName
            #Write-Host -ForegroundColor Green "[74]Processing:" $Path              
            #ProcessFile -Path $Path           
        }
        else  #System.Array
        {
            #System.Array
            #Write-Host -ForegroundColor Green "[33] type.BaseType.FullName:" $type.BaseType.FullName
            <#
            foreach($item in $FileList.GetEnumerator()) 
            {
                Write-Host -ForegroundColor Cyan -BackgroundColor Black "[83] FOLDER $item"
            }
            Write-Host -ForegroundColor Cyan "================================================================================"
            #>
            #get # of folders and files:            
            #$FolderCount = (Get-ChildItem -Path $TemplateDir -Recurse -Directory | Measure-Object).Count
            #$FileCount = (Get-ChildItem -Path $TemplateDir -Recurse -File | Measure-Object).Count
            #Write-Host -ForegroundColor Cyan "[91] $TemplateDir FolderCount = $FolderCount"
            #Write-Host -ForegroundColor Cyan "[92] $TemplateDir FileCount = $FileCount"
            #debug
            #$RootFolder
            #$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')

            $i = 0
            foreach($item in $FileList.GetEnumerator())             
            {                
                #Write-Host -ForegroundColor Yellow "`n================================================================================"
                #Write-Host -ForegroundColor Yellow "[$i] foreach(item in FileList):" (Get-ItemProperty  $item).FullName
                $Path = (Get-ItemProperty  $item | select FullName).FullName
                #Write-Host -ForegroundColor Cyan "`$Path=`"$Path`""
                
                #$childItem = Get-ChildItem -Path $Path.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
                $isDir = (Get-Item $Path) -is [System.IO.DirectoryInfo]
                if($isDir)  
                {  
                    $dirs = Get-ChildItem -Path $Path -Recurse | Sort-Object
                    #Write-Host -ForegroundColor Magenta -BackgroundColor White "[105] Processing file $Path"

                    Foreach ($File In $dirs) 
                    {  
                        $FilePath =  $File.FullName                        
                        $FileName = $File.Name
                        $FileNameBase = $File.BaseName
                        $Extension = $File.Extension
                        $BackUpFolder = ""
                        $DirectoryName = $File.Directory.BaseName
                        $FilePath = $File.FullName
                        $EnvFileBackUp = $DirectoryName + $FileName 
                        $EnvFolder = $EnvFilePath = $null

                        
                        <#
                        If($debugFlag)
                        {
                            Write-Host -ForegroundColor Cyan "`$FilePath=`"$FilePath`""
                            Write-Host -ForegroundColor Cyan "DeployObject.Solution=" $DeployObject.Solution
                            Write-Host -ForegroundColor Cyan "`$DirectoryName=`"$DirectoryName`""
                            Write-Host -ForegroundColor Cyan "`$FileName=`"$FileName`""
                            Write-Host -ForegroundColor Cyan "`$FilePath=`"$FilePath`""                            
                            Write-Host "`$DirectoryName=`"$DirectoryName`""
                            Write-Host "`$DeployObject.Solution=" $DeployObject.Solution
                            Write-Host -ForegroundColor Cyan "`$DirectoryName=`"$DirectoryName`""
                            Write-Host -ForegroundColor Cyan "`$FilePath=`"$FilePath`""
                            Write-Host -ForegroundColor Green "[115] `$FileName=`"$FileName`""
                            Write-Host  -ForegroundColor Green "[115] `$FileNameBase=`"$FileNameBase`""
                            Write-Host  -ForegroundColor Green "[115] `$Extension=`"$Extension`""
                            Write-Host -ForegroundColor Green "[115] `$EnvFileBackUp=`"$EnvFileBackUp`""
                        }                        
                        #>
                        <#
                        $File = Get-Item $FilePath

                        $File = ((Get-ItemProperty  $Path | select FullName).FullName).Split("\")
                        $File = ((Get-ItemProperty  $FilePath | select FullName).FullName).Split("\")
                        $FileNameSplit = $File.Split("\")
                        $File = $FileNameSplit.Get($FileNameSplit.Count-1)
                        $DirectoryName = (Get-ItemProperty  $FilePath).Directory.Name
                        #>                        
                        
                        If($DirectoryName -eq "DPP" -and $DeployObject.Solution -ne "Transfer")
                        {     
                            #C:\GitHub\dtp\Sites\packages\DPP
                            #Write-Host -ForegroundColor Cyan "[170]DPP: `$FileName=`"$FileName`""
                            Switch($FileName)
                            {
                                .env 
                                {   
                                    $EnvFolder = $RootFolder + "Sites\packages\DPP"
                                    $EnvFilePath = $EnvFolder + "\" +  $FileName
                                    <#
                                    Write-Host -ForegroundColor Yellow "[177] DPP: .env "
                                    Write-Host -ForegroundColor Yellow "`$EnvFolder=`"$EnvFolder`""
                                    Write-Host -ForegroundColor Yellow "`$EnvFilePath=`"$EnvFilePath`""
                                   #>
                                } 
                                <#.env.development.local
                                {
                                    $EnvFolder = $RootFolder + "Sites\packages\DPP"
                                    $EnvFilePath = $EnvFolder + "\" +  $FileName
                                    #Write-Host -ForegroundColor White "`$EnvFolder=`"$EnvFolder`""
                                    #Write-Host -ForegroundColor Yellow "[139] `$EnvFilePath=`"$EnvFilePath`""
                                }
                                .env.local
                                {
                                    $EnvFolder = $RootFolder + "Sites\packages\DPP"
                                    $EnvFilePath = $EnvFolder + "\" +  $FileName
                                    #Write-Host -ForegroundColor White "`$EnvFolder=`"$EnvFolder`""
                                    #Write-Host -ForegroundColor Yellow "[139] `$EnvFilePath=`"$EnvFilePath`""
                               
                                }#>
                                local.settings.json
                                {
                                    $EnvFolder = $RootFolder + "API\"  + $DirectoryName 
                                    $EnvFilePath = $EnvFolder + "\" + $FileName    
                                    $EnvFileBackUp = $DirectoryName + "." + $FileName 
                                    <#
                                    Write-Host -ForegroundColor Yellow "[203] DPP: local.settings.json "
                                    Write-Host -ForegroundColor Yellow "`$EnvFolder=`"$EnvFolder`""
                                    Write-Host -ForegroundColor Yellow "`$EnvFilePath=`"$EnvFilePath`""
                                    #>
                                }
                                Default {
                                    break
                                    #Write-Host -ForegroundColor white "[210]DPP: `$FileName=`"$FileName`""
                                }#>
                            }#switch FileName                      
                          
                        }
                        If($DirectoryName -eq "DTP" -and $DeployObject.Solution -ne "Pickup")
                        {
                            #C:\GitHub\dtp\Sites\packages\DTP
                            #Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[218]DTP: `$FileName=`"$FileName`""
                            
                            Switch($FileName)
                            {
                                .env 
                                {                
                                   $EnvFolder = $RootFolder + "Sites\packages\DTP"                            
                                   $EnvFilePath = $EnvFolder + "\" +  $FileName                                   
                                   <#
                                   Write-Host -ForegroundColor Green "DTP"
                                   Write-Host -ForegroundColor Green "`$EnvFolder=`"$EnvFolder`""   
                                   Write-Host -ForegroundColor Green "`$EnvFilePath=`"$EnvFilePath`""
                                   #>
                                } 
                                <#
                                .env.development.local
                                {
                                    $EnvFolder = $RootFolder + "Sites\packages\DTP"
                                    $EnvFilePath = $EnvFolder + "\" +  $FileName
                                    #Write-Host -ForegroundColor White "`$EnvFolder=`"$EnvFolder`""
                                    #Write-Host -ForegroundColor Yellow "[139] `$EnvFilePath=`"$EnvFilePath`""
                               
                                }
                                .env.local
                                {
                                    $EnvFolder = $RootFolder + "Sites\packages\DTP"
                                    $EnvFilePath = $EnvFolder + "\" +  $FileName
                                    #Write-Host -ForegroundColor White "`$EnvFolder=`"$EnvFolder`""
                                    #Write-Host -ForegroundColor Yellow "[139] `$EnvFilePath=`"$EnvFilePath`""
                               
                                }#>
                                local.settings.json
                                {  
                                    $EnvFolder = $RootFolder + "API\dtpapi"   
                                    $EnvFilePath = $EnvFolder + "\" + $FileName         
                                    $EnvFileBackUp = $DirectoryName + "." + $FileName                         
                                    <#
                                    Write-Host -ForegroundColor Yellow "[255] local.settings.json"
                                    Write-Host -ForegroundColor Yellow "`$EnvFolder=`"$EnvFolder`""
                                    Write-Host -ForegroundColor Yellow "`$EnvFilePath=`"$EnvFilePath`""
                                    #>
                                }
                                Default {
                                    break
                                    #Write-Host -ForegroundColor white "[254]DTP: `$FileName=`"$FileName`""
                                }
                            }#switch FileName                           
                        }#If($DirectoryName -eq "DTP" -and $DeployObject.Solution -ne "Pickup")                                                
                        #>
                        <#else
                        {
                            Write-Host -ForegroundColor Red "`$DirectoryName=`"$DirectoryName`""
                            Write-Host -ForegroundColor Red "DeployObject.Solution=" $DeployObject.Solution
                            Write-Host -ForegroundColor Red "EnvFilePath -ne null=" ($EnvFilePath -ne $null)
                            
                        }#> 
                        
                        

                        if ( $EnvFilePath -ne $null )
                        {
                            #Write-Host -ForegroundColor Green "`$EnvFilePath=`"$EnvFilePath`""
                            If( (Test-Path $EnvFilePath) -eq $false)
                            {
                                $EnvFile = New-Item -Path $EnvFolder -Name $FileName -ItemType File
                            }
                            else    
                            {
                                <#
                                Write-Host -ForegroundColor Magenta "`$EnvFolder=`"$EnvFolder`""   
                                Write-Host -ForegroundColor Magenta "`$EnvFilePath=`"$EnvFilePath`""
                                Write-Host -ForegroundColor Magenta "`$FileName=`"$FileName`""
                                Write-Host -ForegroundColor Magenta "[272] Removing and re-creating env file:" $EnvFilePath
                                #>
                                Remove-Item -Path $EnvFilePath
                                $EnvFile = New-Item -Path $EnvFolder -Name $FileName -ItemType File
                                #Write-Host -ForegroundColor GREEN "[279] CREATED NEW env file:" $EnvFile.FullName 
                            }
                        
                            #Write-Host "[144] Created new env file:" $EnvFile.FullName 
                            #Write-Host "`$EnvFile=`"$EnvFile`""
                            <#
                            $json = ConvertTo-Json $DeployObject
                            Write-Host -ForegroundColor Green "`$DeployObject =@'"
                            Write-Host -ForegroundColor Green "["
                            $json
                            Write-Host -ForegroundColor Green "]"
                            Write-Host -ForegroundColor Green "'@"
                            
                            Write-Host -ForegroundColor Yellow "`n================================================================================"
                            $cloudjson = ConvertTo-Json $Cloud                            
                            Write-Host -ForegroundColor Cyan "`$Cloud =@'"
                            Write-Host -ForegroundColor Cyan "["
                            $cloudjson
                            Write-Host -ForegroundColor Cyan "]"
                            Write-Host -ForegroundColor Cyan "'@"

                            #Write-Host "}"
                            
                            #PrintHash -Object $cloudjson
                            #Write-Host -ForegroundColor Yellow "`n================================================================================"
                            #>
                            $envObject = ProcessFile `
                                            -Path $FilePath `
                                            -EnvFile $EnvFilePath `
                                            -DeployObject $DeployObject `
                                            -Cloud $Cloud `
                                            -DeploymentOutput $DeploymentOutput

                        } #env file not null
                        
                        
                        #debug:
                        <#If($debugFlag)
                        {
                            $dtpResources = "C:\GitHub\dtpResources"
                            $currMonth =  Get-Date -Format 'MM'
                            $MonthFolderPath = $dtpResources + "\" +  $currMonth
                            #Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[251] MonthFolderPath="  $MonthFolderPath
                            $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
                            $TodayFolderPath = $MonthFolderPath + "\" +  $TodayFolder
                            $EnvFilePathBackUp = $TodayFolderPath + "\" + $EnvFileBackUp
                            #Write-Host -ForegroundColor Magenta "[250] `$EnvFilePath=`"$EnvFilePath`""   
                            #Write-Host -ForegroundColor Green "[251] `$EnvFilePathBackUp=`"$EnvFilePathBackUp`""
                            #Write-Host "CreateEnvironmentFiles[254] Copying $EnvFilePath to $EnvFilePathBackUp"
                            Copy-Item $EnvFilePath $EnvFilePathBackUp
                            #WriteJsonFile -FilePath $Path -CustomObject $envObject 
                        }#>
                    }#Foreach

                }#isDir
                <#else
                {
                    Write-Host -ForegroundColor Yellow "[117] $Path"
                    #$envObject = ProcessFile -Path $Path
                }#else file
                #>
                
                #Write-Host -ForegroundColor Green "Processing:" $Path  
                #Write-Host -ForegroundColor Cyan "$Path"
                #$Content = Get-Content $Path | Out-String 
                #Write-Host -ForegroundColor Yellow "================================================================================`n"

        
            }# foreach($item in $FileList

        }#Else  #System.Array                
       
        
        #PrintObject -object $DeployObject -Caller $EnvFilePath
        #PrintObject -object $envObject -Caller $EnvFilePath                

        #$FullPath = Get-ChildItem -Path $TemplateDir | select FullName
        #Write-Host -ForegroundColor Yellow "CreateEnvironmentFiles[10] FullPath: " $FullPath.FullName   
        #$Content = Get-Content $DeployObject.OutFileJSON | Out-String 
        #Write-Host $Content
           
    }
}#CreateEnvironmentFiles


Function global:ProcessFile
{
    Param(
        [Parameter(Mandatory = $true)] [String] $Path
       ,[Parameter(Mandatory = $true)] [String] $EnvFile
       ,[Parameter(Mandatory = $true)] [Object] $DeployObject
       ,[Parameter(Mandatory = $true)] [Object] $Cloud
       ,[Parameter(Mandatory = $true)] [Object] $DeploymentOutput
    )
    <#
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Yellow "[$today] START ProcessFile:" $Path
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Green "PARAMETERS:"    
    Write-Host -ForegroundColor Green "`$Path=`"$Path`""
    Write-Host -ForegroundColor Green "`$EnvFile=`"$EnvFile`""
    Write-Host -ForegroundColor Green "================================================================================"
    #>

    <#
    $json = ConvertTo-Json $DeployObject
    Write-Host -ForegroundColor Green "`$DeployObject =@'"
    Write-Host -ForegroundColor Green "["
    $json
    Write-Host -ForegroundColor Green "]"
    Write-Host -ForegroundColor Green "'@"
                            
    Write-Host -ForegroundColor Yellow "`n================================================================================"
    $cloudjson = ConvertTo-Json $Cloud                            
    Write-Host -ForegroundColor Cyan "`$Cloud =@'"
    Write-Host -ForegroundColor Cyan "["
    $cloudjson
    Write-Host -ForegroundColor Cyan "]"
    Write-Host -ForegroundColor Cyan "'@"
    #>

    $i = 0
    $File = ((Get-ItemProperty  $Path | select FullName).FullName).Split("\")
    $FileNameSplit = $File.Split("\")
    $File = $FileNameSplit.Get($FileNameSplit.Count-1)
    $DirectoryName = (Get-ItemProperty $Path).Directory.Name
    $FilePath = (Get-ItemProperty $Path).FullName
    $Extension = (Get-ItemProperty  $Path).Extension
    <#
    Write-Host -ForegroundColor Magenta "CreateEnvironmentFiles.ProcessFile[415] `$File=`"$File`""
    Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles.ProcessFile[416] `$DirectoryName=`"$DirectoryName`""
    Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles.ProcessFile[417] `$FilePath=`"$FilePath`""
    Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles.ProcessFile[418] `$Extension=`"$Extension`""     
    #Write-Host -ForegroundColor Magenta "[112] FileGetType="$File.GetType()
    #>
    #C:\GitHub\dtpResources\rg-dts-prod-lt\DeployedEnvironments\Prod\LocalSetup
    

    If($Extension.Contains('env'))
    {
        foreach($line in Get-Content $FilePath) 
        {                
            if ($line) 
            {
            
                #Write-Host "[39][$i] line.length: " $line.Length
                $firstChar = $line.substring(0, 1)
                if($firstChar -ne "#")
                {
                    #Write-Host -ForegroundColor White $line
                    $envVar = $line.Split("=")[0]
                    $envValue = $line.Split("=")[1]                
                    $lineOut = $envVar + "=" + $envValue 
                    #Write-Host -ForegroundColor White $envVar "=`$DeployObject."
                    #Write-Host -ForegroundColor White $envVar
                    #Write-Host -ForegroundColor Yellow $envValue
                    #Write-Host -ForegroundColor Yellow $lineOut                    

                    if($DirectoryName -eq "DPP")
                    {
                        Switch($File)
                        {
                            .env 
                            {                
                               #Write-Host -ForegroundColor Cyan $envVar" = " + $DPPEnvObject.$envVar
                               $lineOut = "$envVar=" + $DPPEnvObject.$envVar + "`n"
                               $lineOut >> $EnvFile
                               #WriteJsonFile -FilePath $Path -CustomObject $envObject                         
                            } 
                            <#.env.development.local
                            {
                                #Write-Host -ForegroundColor White $line
                                $line  + "`n" >> $EnvFile
                                #Write-Host -ForegroundColor Yellow $line                            
                                #Write-Host -ForegroundColor White $envVar
                                #Write-Host -ForegroundColor Yellow $envValue
                               
                            }#>
                            local.settings.json
                            {
                                #Write-Host -ForegroundColor Green $line
                                #$line  >> $EnvFile
                            }
                            <#Default {
                            }#>
                        }#switch
                
                    }#if($DirectoryName -eq "DPP")

                    elseif($DirectoryName -eq "DTP")
                    {
                        Switch($File)
                        {
                            .env 
                            {                
                                #Write-Host -ForegroundColor White  $envVar" = " + $DTPEnvObject.$envVar
                                $lineOut = $envVar + "=" + $DTPEnvObject.$envVar  + "`n"
                                $lineOut >> $EnvFile
                            }                                
                            <#.env.local
                            {                            
                                #Write-Host -ForegroundColor Yellow $line                            
                                #Write-Host -ForegroundColor White $envVar
                                #Write-Host -ForegroundColor Yellow $envValue
                                $line  + "`n" >> $EnvFile

                            }#>
                            local.settings.json
                            {
                                #$line  >> $EnvFile
                                #Write-Host -ForegroundColor Yellow $line                            
                                #Write-Host -ForegroundColor White $envVar
                                #Write-Host -ForegroundColor Yellow $envValue
                            }
                        
                            Default {
                            }
                        }#switch
                    
                    } #if($DirectoryName -eq "DTP")
                    
                }
                <#else
                {
                    #Write-Host -ForegroundColor Green $line
                    $line  >> $EnvFile
                }
                #Write-Host "[41][$i] firstChar: "$firstChar
                #>                     
            }#if(line)
                
        $i++
        }#foreach($line in Get-Content $Path)    
    
    }#If extension is .env
    ElseIf($Extension.Contains('json')) #Json
    {
        <#
        Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles.ProcessFile[524] Process JSON "
        Write-Host -ForegroundColor Cyan "`$FilePath=`"$FilePath`"" 
        #>
        $json = Get-Content $FilePath | Out-String | ConvertFrom-Json
        
        If($debugFlag)
        {
            $dtpResources = "C:\GitHub\dtpResources"
            $currMonth =  Get-Date -Format 'MM'
            $MonthFolderPath = $dtpResources + "\" +  $currMonth
            <#
            Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[446]" 
            Write-Host -ForegroundColor Cyan "`$MonthFolderPath=`"$MonthFolderPath`""
            #>
            $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')

            $JsonFilePath = "C:\GitHub\dtp\Deploy\LocalSetUp\DTP\local.settings.json"
            $LocalSettingsFileName = "JsonProps.txt"
            $LocalSettingsFilePath = $MonthFolderPath + "\" +  $TodayFolder + "\"       
            BuildLocalSettingsFile `
            -JsonFilePath $JsonFilePath `
            -LocalSettingsFilePath $LocalSettingsFilePath `
            -LocalSettingsFileName $LocalSettingsFileName `
            -DeployObject $DeployObject `
            -Cloud $Cloud         
            #PrintObject -object $json 
            #$json
        }#debugFlag

        

    }#extension is .json
    #>
    return $envObject
}#ProcessFile

