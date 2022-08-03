The PowerShell and the Bicep script creates all the necessary resources in Azure for the application.

**Pre-requesites**:
Azure subscription with privileges to create resources

# 1. Connect to Azure Subscription
1. Open PowerShell ISE (or any other CLI tools you prefer)
2. change to the directory where the bicep file is

   ```powershell
   cd C:\GitHub\dtp\deploy   ```
   ![01 Step](https://github.com/microsoft/dtp/wiki/images/Bicep/01-Bicep.png)
3. Log onto the Azure Subscription

   ```powershell
   Connect-AzAccount -EnvironmentName AzureUSGovernment
   ```

   ![01 Step](https://github.com/microsoft/dtp/wiki/images/Bicep/02-Bicep.png)

# 2. Run `RunDeployment.ps1` to create the 2 App Registrations and Azure resources

The PowerShell script **`RunDeployment.ps1`** creates the 2 app registrations and runs the Bicep script that creates all the necessary resources in Azure for the application.

  - [Method 1: Fill out required parameters inside the script and execute](#method-1-fill-out-required-parameters-inside-the-script-and-execute)

  - [Method 2: By supplying each parameter during execution](#method-2-by-supplying-each-parameter-during-execution)

   The script will ask for each parameters one at a time, or you can supply all the parameters at runtime:
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

1. Open the PowerShell file: `RunDeployment.ps1` and
2. uncomment the line **`218`** by removing the `<#` and
3. remove the matching `#>` from line `225` so the result will look like below:
4. Fill out the parameter values between lines `219` and `224` with the values you prefer.

```powershell
$ApiAppRegName = "APIAPPREGNAME"
$ClientAppRegName= "CLIENTAPPNAME"
$ResGroupName= "RESOURCEGROUPBASENAME"
$Environment = "ENVIRONMENT"
$SiteName = "WEBSITENAME"
$Location = 'LOCATION'

RunDeployment  $ApiAppRegName $ClientAppRegName $ResGroupName $Environment $Location $SiteName
```

5. Save the file
6. On the command line type:

   ```powershell
   .\RunDeployment.ps1
   ```

7. The script will start running and displays the final names of the resources:

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

   1. Navigate back to the **API App Registration** in Azure Active Directory:
      ![API App Reg](https://github.com/microsoft/dtp/wiki/images/Azure/05-Azure.png)
   2.  On the side rail in the **Manage** section, click on **API Permissions**
   3. Click on **Add a permission**
   ![API Permissions](https://github.com/microsoft/dtp/wiki/images/Azure/04-Azure.png)
   4. Click **Microsoft Graph**

      ![Graph](https://github.com/microsoft/dtp/wiki/images/11-AppRegSteps.png)

   5. In the **Microsoft APIs** under the **Select an API** label, select the particular service and give the following permissions:

   Permissions to add:|
   ---------|
   **Azure Storage (1)**  (start typing `'impersonation'` or `'Storage'` in the search field to  Azure Storage)|
   user_impersonation|
   **Microsoft Graph (5)**|
   Directory.AccessAsUser.All|
   Directory.Read.All|
   IdentityUserFlow.Read.All|
   User.Read|
   User.Read.All|

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
   1. Navigate back to Azure Active Directory and select **`App Registrations`**
   2. Select the App registration that was created for the web client: (**`$ClientAppRegName`** in the PowerShell)
   ![Client App Reg](https://github.com/microsoft/dtp/wiki/images/01-AppRegSteps.png)

   3. Click on `Authentication` under the **Manage** section for the app registration:
   4. Click **`Add a platform`**
   5. Click on the **`Web`** tile
   6. Enter the URL for the client web application (you can find this by navigating to your **`Resource group`**, select the **`App Service`** and copy the **URI** that is on the top right of the Overview page)
   ![Web client authentication](https://github.com/microsoft/dtp/wiki/images/03-AppRegSteps.png)

   7. Paste the URL you copied from the App Service's Overview page (below) for the Redirect URI:

   ![Get URL](https://github.com/microsoft/dtp/wiki/images/04-AppRegSteps.png)





## 6. Set up the WebClient App's API Permissions

1. Back under **Manage**, click on **Expose an API**.
2. Click on the **Set** link next to **Application ID URI**, and change the value to `api://WebClientAppId` e.g. `api://appName.azurewebsites.us`.
   ![Set API](https://github.com/microsoft/dtp/wiki/images/05-AppRegSteps.png)

3. Click **Save** to commit your changes. You should now see the **Application ID URI** like below:
   ![AppID](https://github.com/microsoft/dtp/wiki/images/06-AppRegSteps.png)

## 7. Add API App Registration Consent Scope

4. Under the section: **Scopes defined by this API**, Click on **Add a scope**. In the flyout that appears, enter the following values:
    | Property | Value |
    |--|--|
    | Scope name:| **access_as_user** |
    | Who can consent?: | **Admins and users** |
    | Admin and user consent display name: | **Access the API as the current logged-in user** |
    | Admin and user consent description: | **Access the API as the current logged-in user**
    | State | **Enabled**|

5. Click **Add scope** to save your changes.

    ![scope blade](https://github.com/microsoft/dtp/wiki/images/07-AppRegSteps.png)

6. While still in the **Expose and API** blade, then click on the **Add a client application**, under **Authorized client applications**.
7. In the flyout that appears, enter the following values:

   **Client ID**: `API App Registration's ID` e.g. `b2ff3bf3-c01d-4633-b179-6f81efddda9f`

   **Authorized scopes**: Select the scope that ends with `access_as_user`.

   (There should only be 1 scope in this list.)

   ![Client App](https://github.com/microsoft/dtp/wiki/images/Azure/07-Azure.png)

7. Click **Add application** to commit your changes.

## 8. Add API Permissions to your WebClient app


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

9. If you are logged in as the **Global Administrator**, click on the **“Grant admin consent for `tenant-name`”** button to grant admin consent, else inform your Admin to do the same through the portal.

      ![AdminConsent](https://github.com/microsoft/dtp/wiki/images/15-AppRegSteps.png)

   Click **Yes** in the dialog:

      ![AdminYes](https://github.com/microsoft/dtp/wiki/images/17-AppRegSteps.png)

## 9. Add the necessary `App Roles` to the Web Client:

Follow the instructions from [Add App Roles](#6-set-up-the-api-app-registrations-app-roles) to add the necessary app roles for the Web Client.