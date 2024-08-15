
#send in $DeploymentOutput.Outputs
Function global:PrintDeploymentOutputBare{
    Param(
         [Parameter(Mandatory = $true)] [object] $Object
       , [Parameter(Mandatory = $false)] [string] $Caller
        )
    $i=0
    foreach ($item in $Object.Keys)    
    {   

        $key = $item                
        $value = $Object.$key.value        
        $valueOut = "`"" + $value + "`""
        $keyOut = "`$" + $item 
        Write-Host -ForegroundColor White -NoNewline "$keyOut = "
        Write-Host -ForegroundColor Cyan $valueOut
        <#
        Write-Host -ForegroundColor White -NoNewline "`$key=`""
        Write-Host -ForegroundColor Cyan "`"$item`""

        Write-Host -ForegroundColor White -NoNewline "`$value=`""
        Write-Host -ForegroundColor Cyan "`"$value`""
        #>
        $i++       
        
        For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}
        Write-Host "`n"
    }
}#PrintDeploymentOutput



#send in $DeploymentOutput.Outputs
Function global:PrintDeploymentOutput{
    Param(
         [Parameter(Mandatory = $true)] [object] $Object
       , [Parameter(Mandatory = $false)] [string] $Caller
        )
    $i=0
    foreach ($item in $Object.Keys)    
    {   
        $key = $item                
        $value = $Object.$key.value
        $valueOut = "`"" + $value + "`""
        $keyOut = "`$" + $item 
        
        $itemType = $value.GetType().Name
        $baseType = $value.GetType().BaseType

        Switch( $itemType)
        {
            Object[]{
                Write-Host -ForegroundColor Red "Object[]"

                Write-Host -ForegroundColor White "`$itemType=" -NoNewline
                $itemTypeOut = "`"" + $itemType + "`""
                Write-Host -ForegroundColor Yellow $itemTypeOut

                Write-Host -ForegroundColor White "`$baseType=" -NoNewline
                $itemTypeOut = "`"" + $baseType + "`""                
                Write-Host -ForegroundColor Cyan $itemTypeOut
                

                Write-Host -ForegroundColor Yellow  "`$key = " -NoNewline
                Write-Host -ForegroundColor Green $key

                Write-Host -ForegroundColor White "`$item=`"" -NoNewline
                Write-Host -ForegroundColor Green "`"$item`""
                
                Write-Host -ForegroundColor White "`$Object.`$key=`"" -NoNewline                 
                Write-Host -ForegroundColor Cyan $value
                


                                
                #Write-Host -ForegroundColor White  "`$PrevDepOutput.$key.value = "
                Write-Host -ForegroundColor White "`$Object.$key.value = "
                Write-Host -ForegroundColor Cyan $valueOut

                #Write-Host "`$Object.$key.value.Count=" $value.Count
                
                
                #PrintDeploymentOutput -Object $value
                <#
                ForEach($objItem in $value)
                {
                    Write-Host -ForegroundColor Yellow $value[$i]#.GetType()
                    $i++
                }
                #>

            }#Object[]
            <#
            {$itemType -in "String","Int64"}
            {
                Write-Host -ForegroundColor White -NoNewline "`$itemType="
                $itemTypeOut = "`"" + $itemType + "`""
                Write-Host -ForegroundColor Cyan $itemTypeOut
                

                Write-Host -ForegroundColor White -NoNewline "$keyOut = "
                Write-Host -ForegroundColor Cyan $valueOut
                <#
                Write-Host -ForegroundColor White -NoNewline "`$key=`""
                Write-Host -ForegroundColor Cyan "`"$item`""

                Write-Host -ForegroundColor White -NoNewline "`$value=`""
                Write-Host -ForegroundColor Cyan "`"$value`""
                
                $i++       
        
                For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}
                Write-Host "`n"
            }
           
            Default
            {              
                Write-Host "DEFAULT"
                Write-Host -ForegroundColor Yellow -NoNewline "`$itemType="
                $itemTypeOut = "`"" + $itemType + "`""
                Write-Host -ForegroundColor Green $itemTypeOut

                #Write-Host -ForegroundColor White -NoNewline "$keyOut = "
                #Write-Host -ForegroundColor Cyan $valueOut
            }#Default
            #>
        }#Switch( $itemType )
       
    }
}#PrintDeploymentOutput



$DeploymentName="Dts_Transfer_Prod"
$PrevDeployment = Get-AzDeployment -Name $DeploymentName
$PrevDepOutput = $PrevDeployment.Outputs

<#
For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Red "*" -NoNewline}
Write-Host "`n"

Write-Host -ForegroundColor Green "Calling PrintDeploymentOutputBare"
PrintDeploymentOutputBare -Object $PrevDepOutput

For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Red "*" -NoNewline}
Write-Host "`n"

#>
For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Yellow "*" -NoNewline}
Write-Host "`n"

Write-Host -ForegroundColor Green "Calling PrintDeploymentOutput"
PrintDeploymentOutput -Object $PrevDepOutput

For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Yellow "*" -NoNewline}
Write-Host "`n"


<#
$Object = $PrevDepOutput

foreach ($item in $Object.GetEnumerator())  
{
    $itemType = $item.GetType().Name
    #Write-Host -ForegroundColor Cyan -BackgroundColor Black "`$itemType=" $itemType
    Write-Host -ForegroundColor Cyan -BackgroundColor Black $itemType

    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$name="$item.name -NoNewline
    Write-Host -ForegroundColor Cyan -BackgroundColor Black "; `$value="$item.value
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$item.name="$item.name -NoNewline
    Write-Host -ForegroundColor Cyan -BackgroundColor Black "; `$item.value="$item.value
  
}
  #>



  

$ResourceName = "stdtstransferprod001"
try{
$stAccounts = Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Storage/storageAccounts -Name $ResourceName -ErrorAction SilentlyContinue
 }
 catch{
 Write-Host "NOT FOUND"
 }
 
 | Format-Table

 Microsoft.Storage/storageAccounts


$ResourceGroupName= "rg-dts-transfer-prod"
$ResourceName = "sql-dts-transfer-prod"
$azResource = Get-AzSqlServer -ResourceGroupName $ResourceGroupName

$ResourceGroupName= "rg-dtp-transfer-test"
$ResourceName = "sql-dtp-transfer-test"

$azResource = Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $ResourceName

$principalId = $azResource.Identity.PrincipalId.Guid