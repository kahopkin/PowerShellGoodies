$ResourceGroup = 'rg-dev-dtp'
#Target Single Resource Group
# target single resource group
Export-AzViz -ResourceGroup $ResourceGroup -Theme light -OutputFormat png -Show

# target single resource group with more sub-categories
Export-AzViz -ResourceGroup $ResourceGroup -Theme light -OutputFormat png -Show -CategoryDepth 3

# target multiple resource groups
Export-AzViz -ResourceGroup $ResourceGroup -LabelVerbosity 1 -CategoryDepth 1 -Theme light -Show -OutputFormat png

# adding more information in resource label like: Name, type, Provider etc
Export-AzViz -ResourceGroup $ResourceGroup -Theme light -OutputFormat png -Show -LabelVerbosity 2

# adding more information in resource label like: Name, type, Provider etc
Export-AzViz -ResourceGroup $ResourceGroup -Theme light -OutputFormat png -Show -LabelVerbosity 3


Export-AzViz -ResourceGroup $ResourceGroup -Theme light -OutputFormat png -Show -LabelVerbosity 3 -CategoryDepth 2

Export-AzViz -ResourceGroup $ResourceGroup `
    -Theme light `
    -OutputFormat png `
    -Show `
    -LabelVerbosity 3 `
    -CategoryDepth 3 `
    -Direction top-to-bottom `
    -Splines curved `
    -InformationVariable 