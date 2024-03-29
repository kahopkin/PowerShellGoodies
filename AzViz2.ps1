Connect-AzAccount -EnvironmentName AzureUSGovernment
#Target Single Resource Group
# target single resource group
Export-AzViz -ResourceGroup rg-dts-prod-lt -Theme light -OutputFormat png -Show

# target single resource group with more sub-categories
Export-AzViz -ResourceGroup rg-dts-prod-lt -Theme light -OutputFormat png -Show -CategoryDepth 2

# target multiple resource groups
Export-AzViz -ResourceGroup rg-dts-prod-lt, demo-3 -LabelVerbosity 1 -CategoryDepth 1 -Theme light -Show -OutputFormat png

# adding more information in resource label like: Name, type, Provider etc
Export-AzViz -ResourceGroup rg-dts-prod-lt -Theme light -OutputFormat png -Show -LabelVerbosity 2

