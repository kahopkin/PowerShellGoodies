**Azure SQL Database Index and Statistics maintenance**:
* Azure SQL Database is a PaaS solution.  Hence as a managed service,   Azure manages the infrastructure, database availability, backup, restore and compute resources.
* Database maintenance is a regular task for database administrators for optimized performance of application queries. In an on-premise SQL Server, usually, we configure SQL Server Agent jobs with the custom T-SQL scripts or use database maintenance plans for performing index maintenance based on a defined threshold.
* It is a misconception that we do not need to perform database maintenance on Azure databases. Users are responsible for index and statistics maintenance on these databases otherwise performance might degrade over time. However, by default, it has the following configurations in regards to statistics.
	* Auto Create Statistics: True
	* Auto Create Incremental Statistics: False
	* Auto Update Statistics: True
	* Auto Update Incremental Statistics: True

* Azure SQL Database doesn’t come with a SQL Server Agent like Enterprise and Standard Editions. This means we have to find another way to schedule maintenance rather than manually running scripts on a daily or weekly basis. We have a number of different ways to schedule jobs such as Azure Automation Services or Azure Elastic job Agents

* We will follow the steps to automate Azure SQL Database Index and Statistics maintenance 

 1. Create the stored procedure AzureSQLMaintenance.sql [run AzureSQLMaintenance.sql on required Azure SQL Database]
 2. Create Azure Automation account
 3. Import SQL Server module in the Azure Automation Account 
 4. Create Azure SQL Database and Automation credential [Use the same SQL Login used in the connection string used by DTP]
 5. Create Variables to be used in the runbooks for
		* Azure SQL Server FQDN
		* Database name 
 6. Create runbook for Azure SQL Database Index and Statistics maintenance. Edit the runbook with the script below...

 ```powershell
$azureSQLCred = Get-AutomationPSCredential -Name "[AddSQLCredential]"

#Enter the name for your server variable
$SQLServerName = Get-AutomationVariable -Name "[AddVarialbleNameForSQLServer]"

#Enter the name for your database variable
$database = Get-AutomationVariable -Name "[AddVarialbleNameForSQLDatabase]"
	
Write-Output "Azure SQL Database serverFQDN"
 
Write-Output $SQLServerName
 
Write-Output "Azure SQL Database name"
Write-Output $database
 
Write-Output "Your Azure SQL credential name for Automation is:"
Write-Output $azureSQLCred

Invoke-Sqlcmd -ServerInstance $SQLServerName -Credential $azureSQLCred -Database $database `
-Query "exec [dbo].[AzureSQLMaintenance] @Operation='all' ,@LogToTable=1" -QueryTimeout 65535 -ConnectionTimeout 60 -Verbose
``` 

7. Now, perform a test run of the azure runbook. As shown below, it returns the output as below:

	* Displays the total number of indexes, their average fragmentation and number of fragmented indexes
	* It prints statistics information such as total modification and modified statistics
	* It prints the alter index statements that stored procedures execute for index reorg or rebuild

8. In the stored procedure, we specified the parameter @LogToTable value 1. Therefore, it captures queries, status, start time and end time in the [AzureSQLMaintenanceLog] table. You can query this table and view the output, as shown below.
9. Publish the azure automation runbook
10. Once we have tested and published the runbook, we can link to an existing schedule or create a new schedule. Click on the **Link to schedule**.