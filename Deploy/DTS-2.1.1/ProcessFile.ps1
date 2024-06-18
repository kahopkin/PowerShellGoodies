Function global:ProcessFile
{
	Param(
		[Parameter(Mandatory = $true)] [String]$Path
	)

	$i = 0
	$File = ((Get-ItemProperty  $Path | select FullName).FullName).Split("\")
	$FileNameSplit = $File.Split("\")
	$File = $FileNameSplit.Get($FileNameSplit.Count-1)
	Write-Host -ForegroundColor Magenta "[112] File="$File

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

				#Write-Host -ForegroundColor Yellow $envValue
				Write-Host -ForegroundColor Yellow $envVar
				#Write-Host -ForegroundColor Yellow $lineOut

				 Switch($File)
				{
					.env.local {
						 Write-Host -ForegroundColor Green $lineOut
					}
				}#switch
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
