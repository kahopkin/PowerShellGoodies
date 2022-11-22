
Function global:CreateEnvironmentFiles
{
    Param(
       [Parameter(Mandatory = $true)] [String]$RootFolder    
      ,[Parameter(Mandatory = $true)] [String]$TemplateDir    
    )

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Yellow "[$today] START CreateEnvironmentFiles:" $RootFolder
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Green "RootFolder=" $RootFolder  
    Write-Host -ForegroundColor Green "TemplateDir=" $TemplateDir      
    #Write-Host -ForegroundColor Green "FileList.Count: " $FileList.Count
    #Write-Host -ForegroundColor Green "FileList:" 

    if (Test-Path $TemplateDir) 
    {        
        $FileListJson = ConvertTo-Json (Get-ChildItem -Path $TemplateDir | Select FullName).FullName
        $FileList = $FileListJson | Out-String | ConvertFrom-Json

        Write-Host -ForegroundColor Green "FileList:"     
        $type = $FileList.GetType() 
        #System.Object
        If( $type.BaseType.FullName -eq "System.Object" )
        {
            Write-Host -ForegroundColor Yellow "[28] type.BaseType.FullName:" $type.BaseType.FullName
            Write-Host -ForegroundColor Yellow "[29] FileList:" $FileList
            $Path = (Get-ItemProperty  $FileList | select FullName).FullName
            Write-Host -ForegroundColor Green "Processing:" $Path  
            
            ProcessFile -Path $Path
            <#$Content = Get-Content $Path | Out-String
            $i = 0
            foreach($line in Get-Content $Path) 
            {                
                if ($line) 
                {
                    #Write-Host -ForegroundColor White $line
                    #Write-Host "[39][$i] line.length: " $line.Length
                    $firstChar = $line.substring(0, 1)
                    if($firstChar -ne "#")
                    {
                        $envVar = $line.Split("=")[0]
                        Write-Host -ForegroundColor Yellow $envVar
                        $global:DeployInfo = [ordered]@{

                        }
                    }
                    else
                    {
                        #Write-Host -ForegroundColor White $line
                    }
                    #Write-Host "[41][$i] firstChar: "$firstChar
                  
                }#if line
                
                $i++
                }#foreach($line in Get-Content $Path)     
                #>       
        }
        else  #System.Array
        {
            #System.Array
            Write-Host -ForegroundColor Green "[33] type.BaseType.FullName:" $type.BaseType.FullName
            foreach($item in $FileList.GetEnumerator()) 
            {
                Write-Host -ForegroundColor Cyan -BackgroundColor Black $item  
            }

            Write-Host -ForegroundColor Yellow "================================================================================"
            
            #get # of folders and files:
            $FolderCount = (Get-ChildItem -Path $TemplateDir -Recurse -Directory | Measure-Object).Count
            $FileCount = (Get-ChildItem -Path $TemplateDir -Recurse -File | Measure-Object).Count
            Write-Host -ForegroundColor Cyan "# of folders=" $FolderCount
            Write-Host -ForegroundColor Cyan "# of FileCount=" $FileCount

            $i = 0
            foreach($item in $FileList.GetEnumerator()) 
            {
            
                $Path = (Get-ItemProperty  $item | select FullName).FullName
                Write-Host -ForegroundColor Green "Processing:" $Path  
                #$Content = Get-Content $Path | Out-String 
                ProcessFile -Path $Path          

            }# foreach($item in $FileList


        }#Else  #System.Array                
                
        $FullPath = Get-ChildItem -Path $TemplateDir | select FullName
        #Write-Host -ForegroundColor Yellow "CreateEnvironmentFiles[10] FullPath: " $FullPath.FullName   
        #$Content = Get-Content $OutFileJSON | Out-String 
        #Write-Host $Content
           
    }
}#CreateEnvironmentFiles



Function global:ProcessFile
{
    Param(
       [Parameter(Mandatory = $true)] [String]$Path          
    )

    $i = 0
    foreach($line in Get-Content $Path) 
    {                
        if ($line) 
        {
            #Write-Host -ForegroundColor White $line
            #Write-Host "[39][$i] line.length: " $line.Length
            $firstChar = $line.substring(0, 1)
            if($firstChar -ne "#")
            {
                $envVar = $line.Split("=")[0]
                $envValue = $line.Split("=")[1]                
                $lineOut = $envVar + "=" + $envValue

                Write-Host -ForegroundColor Yellow $envValue
                #Write-Host -ForegroundColor Yellow $envVar
                #Write-Host -ForegroundColor Yellow $lineOut
                $global:envObject = [ordered]@{
                    GENERATE_SOURCEMAP = "$false";
                    REACT_APP_AAD_CLIENT_ID = "REACT_APP_AAD_CLIENT_ID";
                    REACT_APP_AAD_AUTHORITY = "REACT_APP_AAD_AUTHORITY";
                    REACT_APP_AAD_REDIRECT_URI = "REACT_APP_AAD_REDIRECT_URI";
                    REACT_APP_LOGIN_SCOPES = "array:User.Read";
                    REACT_APP_GRAPH_ENDPOINT = "https://graph.microsoft.us/v1.0/me";
                    REACT_APP_GRAPH_SCOPES = "array:User.Read";
                    REACT_APP_DPP_API_ENDPOINT = "REACT_APP_DPP_API_ENDPOINT";
                    REACT_APP_DPP_API_SCOPES = "REACT_APP_DPP_API_SCOPES";
                }
            }
            else
            {
                #Write-Host -ForegroundColor White $line
            }
            #Write-Host "[41][$i] firstChar: "$firstChar
                  
        }#if line
                
        $i++
        }#foreach($line in Get-Content $Path)    
}#ProcessFile



$RootFolder = "C:\GitHub\dtp\Deploy\LocalSetUp\"
$TemplateDir = $RootFolder + "DTP"
$TemplateDir = $RootFolder + "test"
CreateEnvironmentFiles -RootFolder $RootFolder -TemplateDir $TemplateDir

<#
$TemplateDir = $RootFolder + "DTP"
CreateEnvironmentFiles
#>

