<#
How to deploy Azure Function Apps with Powershell
https://www.davidguida.net/how-to-deploy-azure-function-apps-with-powershell/
#
#>

<#
building a temporary path using a GUID and calling dotnet publish to compile the Project 
and output the binaries to it. 
Then we generate a Zip archive and get rid of the publish folder.
#>
function publish{
    param(
        $projectName        
    )

    $projectPath="src/$($projectName)/$($projectName).csproj"
    $publishDestPath="publish/" + [guid]::NewGuid().ToString()

    log "publishing project '$($projectName)' in folder '$($publishDestPath)' ..." 
    dotnet publish $projectPath -c Release -o $publishDestPath

    $zipArchiveFullPath="$($publishDestPath).Zip"
    log "creating zip archive '$($zipArchiveFullPath)'"
    $compress = @{
        Path = $publishDestPath + "/*"
        CompressionLevel = "Fastest"
        DestinationPath = $zipArchiveFullPath
    }
    Compress-Archive @compress

    log "cleaning up ..."
    Remove-Item -path "$($publishDestPath)" -recurse

    return $zipArchiveFullPath
}


function log{
    param(
        $text
    )

    write-host $text -ForegroundColor Yellow -BackgroundColor DarkGreen
}

#deploy it to Azure
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

<#
#set some basic application settings, right after the deployment
{
  "FUNCTIONS_WORKER_RUNTIME": "dotnet",  
  "ASPNETCORE_ENVIRONMENT": "DEV",
  "Foo": "bar"
}
#>
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

#put everything together and call it
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

#send the artifact to the cloud:
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