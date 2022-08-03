#DeployAzFunction

<#
https://www.davidguida.net/how-to-deploy-azure-function-apps-with-powershell/
#>

#to create the Release Artifact.
Function Publish{
    param(
        $projectName        
    )

    $projectPath="src/$($projectName)/$($projectName).csproj"
    Write-Host -ForegroundColor Cyan "Publish[14] projectPath:" $projectPath

    $publishDestPath="publish/" + [guid]::NewGuid().ToString()
    Write-Host -ForegroundColor Cyan "Publish[17]: publishDestPath"$publishDestPath

    log "publishing project '$($projectName)' in folder '$($publishDestPath)' ..." 
    Write-Host -ForegroundColor Cyan "Publish[20] publishing project '$($projectName)' in folder '$($publishDestPath)' ..." 

    dotnet publish $projectPath -c Release -o $publishDestPath

    $zipArchiveFullPath="$($publishDestPath).Zip"
    Write-Host -ForegroundColor Cyan "Publish[25]: zipArchiveFullPath" $zipArchiveFullPath
    
    log "creating zip archive '$($zipArchiveFullPath)'"
    Write-Host -ForegroundColor Cyan "creating zip archive '$($zipArchiveFullPath)'"
    $compress = @{
        Path = $publishDestPath + "/*"
        CompressionLevel = "Fastest"
        DestinationPath = $zipArchiveFullPath
    }
    Compress-Archive @compress

    log "cleaning up ..."
    Write-Host -ForegroundColor Cyan "Publish[37]: cleaning up ..."
    Remove-Item -path "$($publishDestPath)" -recurse

    return $zipArchiveFullPath
}#Publish




#Write-Host -ForegroundColor Cyan "Publish[]: "

function log{
    param(
        $text
    )

    write-host $text -ForegroundColor Yellow -BackgroundColor DarkGreen
}

Publish -projectName dtp


function deploy{
    param(
        $zipArchiveFullPath,
        $subscription,
        $resourceGroup,        
        $appName
    )    

    log "deploying '$($appName)' to Resource Group '$($resourceGroup)' in Subscription '$($subscription)' from zip '$($zipArchiveFullPath)' ..."
    az functionapp deployment source config-zip -g "$($resourceGroup)" -n "$($appName)" --src "$($zipArchiveFullPath)" --subscription "$($subscription)"   
}


function setConfig{
    param(
        $subscription,
        $resourceGroup,        
        $appName,
        $configPath
    )
    log "updating application config..."
    az functionapp config appsettings set --name "$($appName)" --resource-group "$($resourceGroup)" --subscription "$($subscription)" --settings @$configPath
}
#The config file can be something like this:
<#
{
  "FUNCTIONS_WORKER_RUNTIME": "dotnet",  
  "ASPNETCORE_ENVIRONMENT": "DEV",
  "Foo": "bar"
}


function createArtifact {
    param(
        $appName
    )
    $zipPath = publish $appName
    if ($zipPath -is [array]) {
        $zipPath = $zipPath[$zipPath.Length - 1]
    }
    return $zipPath
}




function deployInstance {
    param(      
        $zipPath,  
        $subscription,
        $resourceGroup,        
        $appName,
        $configPath
    )

    deploy $zipPath $subscription $resourceGroup $appName

    if(![string]::IsNullOrEmpty($configPath)){
        setConfig $subscription $resourceGroup $appName $configPath
    }
}



$zipPath = createArtifact "MyAwesomeProject" 
deployInstance $zipPath "MyFirstSubscription" "MyFirstResourceGroup" "MyAwesomeProject1" "DEV.settings.json"
deployInstance $zipPath "MySecondSubscription" "MySecondResourceGroup" "MyAwesomeProject2" "DEV.settings.json"
deployInstance $zipPath "MyThirdSubscription" "MyThirdResourceGroup" "MyAwesomeProject3" "DEV.settings.json"

#>