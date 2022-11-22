New-AzSubscriptionDeployment `
        -Name Deployment_07-05-2022-10-25-53 `
        -Location usgovvirginia `
        -TemplateFile ..\main.bicep `
        -EnvironmentType dev `
        -ResourceGroupName rg-tuesite-dev `
        -SiteName tuesite `
        -AppName tuesite `
        -ApiClientId 5afcd8eb-82f0-4a21-8c00-30713f13dd14 `
        -ApiClientSecret 2n63-mM~mOPLemDUtT3xa~JUt5I.J3G4hx `
        -TemplateParameterFile ..\main.parameters.dev.json


git checkout fa5e84d8c1ad3f0c43001b822f2c32dd86199868 .
git add .
git commit -m "Reverting to <commit-id>"
git push