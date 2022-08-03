The PowerShell and the Bicep script creates all the necessary resources in Azure for the application.

**Pre-requesites**:
* Azure subscription with privileges to create resources
* Latest version of **PowerShell, Azure PowerShell and Microsoft Graph PowerShell**:

```powershell
#Set execution policy in PowerShell to remote signed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

* Make sure you have the latest version of PowerShellGet. For more info on installing the latest version: [INstalling PowerShell on Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
* Run:
```powershell
#Check which version of PowerShell you have installed.
$PSVersionTable.PSVersion
#Install latest version
Install-Module -Name PowerShellGet -Force
```
* Azure PowerShell modules installed (NOT AzureRM)
```powershell
#check Az module:
Get-InstalledModule Az
#If not present, run below to install
Install-Module -Name Az.Resources -Repository PSGallery -Scope CurrentUser
```

* Install the Microsoft Graph Module:
```powershell
# Installing the Module

# Installing the Graph PowerShell module with no previous versions installed
Install-module Microsoft.Graph

# If upgrading from our preview modules, run install-module with AllowClobber and Force parameter to avoid command name conflicts
Install-Module Microsoft.Graph -AllowClobber -Force

# Updating from an earlier version of MS Graph PowerShell installed from PS Gallery
Update-module Microsoft.Graph
```

*Import the Graph.Applications Module:
```powershell
Import-Module -name Microsoft.Graph.Applications
```

* Bicep installed
In order to successfully create all the necessary Azure resources for the application,
you need Bicep installed.
If not installed, please see [https://aka.ms/bicep-install](https://aka.ms/bicep-install) to install. `Note: Your environment path may need to be updated manually with the location of your Bicep installation and may also require you to reboot your PC before continuing.`

There are two different types of installations for the application:
Both require for you to change the values of the same parameters that define
the names of all the resources:

1. **Method 1 Deployment**: This method automatically creates the App Registrations based on the parameters you pass in
but it requires all the configuration steps to be performed manually.
To deploy using this method, run the **C:\GitHub\dtp\Deploy\RunDeployment.ps1 ** script by following
the deploy instructions under **Method 1 Deployment**
```powershell
.\RunDeployment.ps1
#i.e.:
PS C:\GitHub\dtp06022022\Deploy> .\RunDeployment.ps1
```

2. **Method 2 Deployment**: This method does 100% automated creation and configuration
of all the resources needed by the application.
It creates and configures both App Registrations and creates all the Azure Resources in the
Resource Group that gets created.
Please read the notes on the naming conventions in the documentation.
In order to use this method, you need to navigate to the **dtp\Deploy\powershell** folder
and change the values for the resource parameters in the **InitiateDeploymentProcess.ps1**
```powershell
$ApiAppRegName = "APIAPPREGNAME"
$ClientAppRegName= "CLIENTAPPNAME"
$ResGroupName= "RESOURCEGROUPBASENAME"
$Environment = "ENVIRONMENT"
$SiteName = "WEBSITENAME"
$Location = "'LOCATION"
and run the script:
```
Save the file and run:
```powershell
 .\InitiateDeploymentProcess.ps1

#i.e.:
PS C:\GitHub\dtp\Deploy\powershell> .\InitiateDeploymentProcess.ps1
```

# 1. Connect to Azure Subscription
1. Open PowerShell ISE as admin (or any other CLI tools you prefer)
2. Change the directory to the Deploy folder.
3. Log onto the Azure Subscription

   ```powershell
   Connect-AzAccount -EnvironmentName AzureUSGovernment
   ```

# 2. Run `RunDeployment.ps1` to create the 2 App Registrations and Azure resources

The PowerShell script **`RunDeployment.ps1`** creates the 2 app registrations and runs the Bicep script that creates all the necessary resources in Azure for the application.

  - [Method 1: Fill out required parameters inside the script and execute](#method-1-fill-out-required-parameters-inside-the-script-and-execute)

  - [Method 2: By supplying each parameter during execution](#method-2-by-supplying-each-parameter-during-execution)

   The script will ask for each parameter one at a time, or you can supply all the parameters at runtime:
   Add the necessary parameters for the Azure Resources that the script will create:

   Resource Name  | Value
   ---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   $ApiAppRegName | The App Registration's name that is configured with the Function App
   $ResGroupName  | Resource Group Base Name. FInal name will have the format:[$ResGroupName][ResGroup][TitleCase([Environment])].  If set as **'dtp'** and the environment given is **'dev'**, the final resource group name will be: **dtpResGroupDev**
   $Environment   | [test\|dev\|prod]
   $Location      | [usgovvirginia\|usgovtexas\|usgovarizona\|usdodeast\|usdodcentral]
   $SiteName      | This is what the web client website will be named. i.e. https://**mysite**.testmon.azurewebsites.us

Possible **LOCATION** values:

Common Name     | Display Name   | Location Name
----------------|----------------|--------------
US Gov Virginia | USGov Virginia | usgovvirginia
US Gov Texas    | USGov Texas    | usgovtexas
US Gov Arizona  | USGov Arizona  | usgovarizona
US DoD East     | USDoD East     | usdodeast
US DoD Central  | USDoD Central  | usdodcentral

Possible **ENVIRONMENT** values:
ENVIRONMENT|
-----------|
prod|
test|
dev|


## Method 1: Fill out required parameters inside the script and execute

1. Open the PowerShell file: `RunDeployment.ps1`.
2. Search for `#ScriptVariables`.
3. Remove the comments under #ScriptVariables, they look like `<#` and `#>`.
4. Fill out the parameter values with the values you prefer.

```powershell
#ScriptVariables
$ApiAppRegName = "APIAPPREGNAME"
$ClientAppRegName= "CLIENTAPPNAME"
$ResGroupName= "RESOURCEGROUPBASENAME"
$Environment = "ENVIRONMENT"
$SiteName = "WEBSITENAME"
$Location = 'LOCATION'

RunDeployment  $ApiAppRegName $ClientAppRegName $ResGroupName $Environment $Location $SiteName
```

1. Save the file
2. On the command line type:

   ```powershell
   .\RunDeployment.ps1
   ```

3. The script will start running and displays the final names of the resources:

![Output 09](https://github.com/microsoft/dtp/wiki/images/Bicep/09-Bicep.png)

The final output looks like this:

![bicepOutput](https://github.com/microsoft/dtp/wiki/images//Bicep/11-Bicep.png)


## Method 2: By supplying each parameter during execution

Start typing: .\RunDeployment and click on the command line and select the script name:

   ```powershell
   .\RunDeployment.ps1
   ```

![RunDeployment](https://github.com/microsoft/dtp/wiki/images/Bicep/03-Bicep.png)

**Api App Registration:**

![Api](https://github.com/microsoft/dtp/wiki/images//Bicep/04-Bicep.png)

**WebClient App Registration:**

![WebClient](https://github.com/microsoft/dtp/wiki/images//Bicep/10-Bicep.png)

**Resource Group:**

![ResGroup](https://github.com/microsoft/dtp/wiki/images//Bicep/05-Bicep.png)

**Environment type to deploy:**

![Env](https://github.com/microsoft/dtp/wiki/images/Bicep/06-Bicep.png)

**Location:**

![Location](https://github.com/microsoft/dtp/wiki/images/Bicep/07-Bicep.png)

**Web Client SiteName:**

![SiteName](https://github.com/microsoft/dtp/wiki/images/Bicep/08-Bicep.png)

**PS output:**

![Output](https://github.com/microsoft/dtp/wiki/images/Bicep/09-Bicep.png)

**Bicep final output:**

![bicepOutput](https://github.com/microsoft/dtp/wiki/images/Bicep/11-Bicep.png)

The Bicep script creates all the necessary resources in Azure for the application.


## Azure Resources created with the script:

   At this point, you have created the 2 app registrations and all necessary Azure resources.  You should see the resources in Azure similar to what is in below screenshots.  Note: the names of the resources are derived from the parameters you have given when running the script.

   ### **App Registrations**

   ![App Registrations](https://github.com/microsoft/dtp/wiki/images/Bicep/12-Bicep.png)

   ### Azure Resource Group and its resources:

   ![Resources](https://github.com/microsoft/dtp/wiki/images/Bicep/13-Bicep.png)


# 3. Configure the API App Registration's `API Permissions` Configurations:

   1. Go to **Azure Active Directory**, then in the left menu, select **App Registrations**
   2. In the **Owned Applications** tab, Click on the link to the API Application just created, similar to the example below:
      ![API App Reg](https://github.com/microsoft/dtp/wiki/images/Azure/05-Azure.png)
   3.  On the side rail in the **Manage** section, click on **API Permissions**
   4. Click on **Add a permission**
   ![API Permissions](https://github.com/microsoft/dtp/wiki/images/Azure/04-Azure.png)
   5. Click **Microsoft Graph**, then **Delegated permissions**
      ![Graph](https://github.com/microsoft/dtp/wiki/images/11-AppRegSteps.png)
   6. Make the following selections:
      1. Directory.AccessAsUser.All
      2. Directory.Read.All
      3. IdentityUserFlow.Read.All
      4. User.Read
      5. User.Read.All
   7. Click the **Add permissions** button to add these 5 Microsoft Graph permissions
   8. For the second time, click the **Add a permission** button
   9. Select **Azure Storage**
   10. Select **user_imppersonation**, then the **Add permissions** button
   11. In the **Microsoft APIs** under the **Select an API** label, select the particular service and give the following permissions:

The final screen should look like below:

   ![API Permission](https://github.com/microsoft/dtp/wiki/images/18-AppRegSteps.png)

# 4. Configure the API's `Expose and API`:
   1. Click the `**Expose an API**` menu under **Manage** section to set up the API App Regisration's scope [Expose an API]

   2. Click on the **Set** link next to **Application ID URI**, and change the value to
   `api://ApiAppRegistrationID` e.g. `api://435ed1e5-e4ab-4205-a2f5-2726945d19be`

      ![Set API](https://github.com/microsoft/dtp/wiki/images/05-AppRegSteps.png)

   3. Click **Save** to commit your changes. You should now see the **Application ID URI** like below:
   ![AppID](https://github.com/microsoft/dtp/wiki/images/06-AppRegSteps.png)

# 5. Add Consent Scope to the API App Registration:

 1. Under the section: **Scopes defined by this API**, Click on **Add a scope**,
 2. Under **Scopes defined by this API**.
   In the flyout that appears, enter the following values:

    | Property | Value |
    |--|--|
    | Scope name:| **access_as_user** |
    | Who can consent?: | **Admins and users** |
    | Admin and user consent display name: | **Access the API as the current logged-in user** |
    | Admin and user consent description: | **Access the API as the current logged-in user** |


# 6. Set up the API App Registration's App Roles
   ## 6.1. Admin App Role
   1. Under the App Roles section for the API app registration, click on **App Roles**

   ![App Roles 01](https://github.com/microsoft/dtp/wiki/images/Azure/01-Azure.png)

   2. Click **Create app role** and fill out as shown in the table and image below:

   Field | Value |
   ---------|----------|
   Display name | DTP API Admins |
   Allowed member types	 |Users/Groups |
   Value	 |DTPAPI.Admins |
   Description |	Admin users of the DTP API |
   Do you want to enable this app role? |	Yes |

 ![Add Admin role](https://github.com/microsoft/dtp/wiki/images/Azure/02-Azure.png)

   ## 6.2 Add the `Users` App Role
   3. Click **Create app role** again to add the **`Users`** App Role.
   4. Fill out as shown in the table and image below: :

      Field|Value|
      ---------|----------|
      Display name|DTP API Users|
      Allowed member types|Users/Groups|
      Value|DTPAPI.Users|
      Description|Standard users of the DTP API|
      Do you want to enable this app role?|Yes|

         ![Users App Role](https://github.com/microsoft/dtp/wiki/images/Azure/03-Azure.png)

   5. Click on **Apply** to save the changes.  The final screen for the **App roles** should look like below:
   ![App Role Final](https://github.com/microsoft/dtp/wiki/images/Azure/06-Azure.png)


# 7. Set up the Web client app registration's `Authentication`:
   1. Navigate back to Azure Active Directory and under Manage, select **`App Registrations`**
   2. Select the App registration that was created for the web client: (**`$ClientAppRegName`** in the PowerShell)
   ![Client App Reg](https://github.com/microsoft/dtp/wiki/images/01-AppRegSteps.png)

   3. Click on `Authentication` under the **Manage** section for the app registration:
   4. Click **`Add a platform`**
   5. Click on the **`Web`** tile
   6. Enter the URL for the client web application (you can find this by navigating to your **`Resource group`**, select the **`App Service`** and copy the **URI** that is on the top right of the Overview page)
   ![Web client authentication](https://github.com/microsoft/dtp/wiki/images/03-AppRegSteps.png)

   7. Paste the URL you copied from the App Service's Overview page (below) for the Redirect URI:

   ![Get URL](https://github.com/microsoft/dtp/wiki/images/04-AppRegSteps.png)

# 8. Add API Permissions to your WebClient app

1. Navigate back to the Azure Active Directory's **App Registrations** list view and select the web client app registration.

   ![WebClient App Reg](https://github.com/microsoft/dtp/wiki/images/09-AppRegSteps.png)
2. Select **API Permissions** blade from the left hand side.

3. Click on **Add a permission** button to add permission to your app.

   ![App Permissions](https://github.com/microsoft/dtp/wiki/images/10-AppRegSteps.png)

4. In Microsoft APIs under Select an API label, select the Microsoft Graph service.

   ![Graph](https://github.com/microsoft/dtp/wiki/images/11-AppRegSteps.png)

5. Select **Delegated permissions** and add the permissions listed in the table below:

    | Permissions to add:|
    |--|
    |**IdentityUserFlow.Read.All**  *start typing 'Identity' in the search field to show related permissions*|
    | **offline_access**|
    | **openid**|
    | **profile**|
    | **User.Read**|
    ||

   ![permissions](https://github.com/microsoft/dtp/wiki/images/12-AppRegSteps.png)
6. In the Select Permissions search window start typing "Identity" and then select `IdentityUserFlow.Read.All`

    ![Identity permission](https://github.com/microsoft/dtp/wiki/images/14-AppRegSteps.png)
7. Click "Add permissions" to commit your changes.

8. Click on **Add a permission** again and select **`APIs my organization uses`**
     - In the search field, start typing the name of your **API app registration name** (or simply click on it if it is readily visible) and select it

       ![Org App API](https://github.com/microsoft/dtp/wiki/images/13-AppRegSteps.png)

   - Select **Delegated Permissions**
   - Select the expanded permission: **XXX.Users**
   - Click **Add Permissions**

   ![Org App API](https://github.com/microsoft/dtp/wiki/images/16-AppRegSteps.png)

   - Click on **Add permissions** to commit your changes. You should see the results as shown below:

   ![Azure AD API permissions](https://github.com/microsoft/dtp/wiki/images/multitenant_app_permissions_2.png)

9. If you are logged in as the **Global Administrator**, click on the **Grant admin consent for `tenant-name`** button to grant admin consent, else inform your Admin to do the same through the portal.

      ![AdminConsent](https://github.com/microsoft/dtp/wiki/images/15-AppRegSteps.png)

   Click **Yes** in the dialog:

      ![AdminYes](https://github.com/microsoft/dtp/wiki/images/17-AppRegSteps.png)

# 9. Add the necessary `App Roles` to the Web Client:

Follow the instructions from [Add App Roles](#6-set-up-the-api-app-registrations-app-roles) to add the necessary app roles for the Web Client.

# 10. Deploy Client Web App and Azure Function App
## Zip Client Deployment Files
1. Open a local branch of the code in [Visual Studio Code](https://code.visualstudio.com/).
2. Ensure you're working with the latest code base.
3. Run the following commands in the terminal. If missing, you can use the following shortcut:

![Visual Studio Code Terminal](https://github.com/microsoft/dtp/wiki/images/HowToRunDeployScript/VSCodeTerminalDisplay.png)

   ```powershell
   # Install latest dependencies
    npm install
    ```
   ```powershell
   # Fix vulnerabilities
   npm audit fix
   ```
   ```powershell
   # Build client application
   npm run-script build
   ```
   ```powershell
   # Navigate to build folder
   cd build
   ```
   ```powershell
   # Zip deployment files. Replace <..> in the following command, without any quotes:
   # - <Deployment Path>: The full deployment path and file name, for example C:\Deploy\ClientDeployment.zip
   Compress-Archive -Path * -DestinationPath <DeploymentPath>
   ```
4. Verify zip file was created in the deployment folder specified.

## Deploy Client Deployment Files to Azure

   1. Open PowerShell `as Administrator`
   2. Log into Azure
   ```powershell
   # A web browser will open prompting you to authenticate your Azure account.
   az login
   ```
   3. Publish deployment files to Azure.
   ```powershell
   # Publish deployment files to Azure. Replace <..> in the following command, without any quotes:
   # - <RG>: this is the Resource Group Name
   # - <SiteName>: this is the site name, which can be found in Azure and is also specified in your deployment output file from the scripts you ran earlier.
   # - <Path>: this is the physical path to your zip file and must include the full file name
   Publish-AzWebApp -ResourceGroupName <RG> -Name <SiteName> -ArchivePath <Path>
   ```
   4. Successfull deployment returns a fair amount of output, followed by a command prompt. It will be obvious if you get an error - also some red text.
   5. In Azure, you can verify deployment by:
      1. Open the App Service in your Resource Group.
      2. Under Deployment, select Deployment Center.
      3. Select Logs from the tabbed menu.
 
## Zip Server-Side Function Application
1. Open Visual Studio Code.
2. Navigate to the local `../API/dtpapi folder`

   ```powershell
   # Build the project. It will inform you if it succeeded.
    dotnet build
    ```
   ```powershell
   # Publish the application and its dependencies to a folder for deployment to Azure.
   # - <DeploymentFolderName>: The name of the deployment folder within the same folder scructure. Not a full path and no extention.
   dotnet publish -c Release -o <DeploymentFolderName>
   ```
   ```powershell
   # Change to the folder you published to in the previous step.
   cd <DeploymentFolderName>
   ```
   ```powershell
   # 
   cd build
   ```
   ```powershell
   # Zip deployment files. Replace <..> in the following command, without quotes:
   # - <Deployment Path>: The full deployment path and file name, for example C:\Deploy\ClientDeployment.zip
   Compress-Archive -Path * -DestinationPath <DeploymentPath>
   ```
3. Verify zip file was created in the deployment folder specified.

## Deploy Server-Side Function Application to Azure
   1. Open PowerShell `as Administrator`
   2. Log into Azure
   ```powershell
   # A web browser will open prompting you to authenticate your Azure account.
   az login
   ```
   3. Publish deployment files to Azure. There are currently two options:
      Using `Publish-AzWebApp`. Currently, this option does not remove objects previously removed from the application.
   ```powershell
   # Publish deployment files to Azure. Replace <..> in the following command, without any quotes:
   # - <RG>: this is the Resource Group Name
   # - <SiteName>: this is the site name, which can be found in Azure and is also specified in your deployment output file from the scripts you ran earlier.
   # - <Path>: this is the physical path to your zip file and must include the full file name
   Publish-AzWebApp -ResourceGroupName <RG> -Name <SiteName> -ArchivePath <Path>
   ```
      Using `az functionapp`
   ```powershell
   # Publish deployment files to Azure. Replace <..> in the following command, without any quotes:
   # - <RG>: this is the Resource Group Name
   # - <AppName>: this is the Function</u></b> name - not the site name, which can be found in Azure and is also specified in your deployment output file from the scripts you ran earlier.
   # - <Path>: this is the physical path to your zip file and must include the full file name
   az functionapp deployment source config-zip -g <RG> -n <AppName> --src <Path>
   ```
   4. Successfull deployment returns a fair amount of output, followed by a command prompt. It will be obvious if you get an error - also some red text.
   5. In Azure, you can verify deployment by:
      1. Open the Function App in your Resource Group.
      2. Under Deployment, select Deployment Center.
      3. Select Logs from the tabbed menu.


