﻿$modulePath = 'C:\Program Files\WindowsPowerShell\Modules'

# Delete module...
Remove-Item -Path "$modulePath\xSharePointAdministration" -Force -Recurse 

# Create Farm Solution Resource
$Name        = New-xDscResourceProperty -Name Name -Type String -Attribute Key -Description "The name of the farm solution (i.e. mysolution.wsp)."
$Ensure      = New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -ValidateSet @("Present", "Absent") -Description "Set this to 'Present' to ensure that the solution is deployed. Set it to 'Absent' to ensure that the solution is retracted and removed from the farm."
$LiteralPath = New-xDscResourceProperty -Name LiteralPath -Type String -Attribute Required -Description "The path to the solution in the drop folder or file system."
$Version     = New-xDscResourceProperty -Name Version -Type String -Attribute Write -Description "The version of the assembly (default is '1.0')." 
$WebAppa     = New-xDscResourceProperty -Name WebApplications -Type String[] -Attribute Write -Description "One or more URL's of web application that the solution is deployed to. Leave empty to deploy to all web applications."
$Deployed    = New-xDscResourceProperty -Name Deployed -Type Boolean -Attribute Write -Description "Default 'true'. Set this to 'false' to retract the solution but not remove it from the store."
$Local       = New-xDscResourceProperty -Name Local -Type Boolean -Attribute Write -Description "Set 'Local' to true if you only deploy the solution on a single server."
$Force       = New-xDscResourceProperty -Name Force -Type Boolean -Attribute Write -Description "Set 'Force' to true to force the deployment in case of errors. Be careful with this switch!"

New-xDscResource -Name ALIS_xFarmSolution -FriendlyName FarmSolution -ModuleName xSharePointAdministration -Property @($Name, $Ensure, $LiteralPath, $Version, $WebAppa, $Deployed, $Local, $Force) -Path $modulePath

Copy-Item .\DSCResources\ALIS_xFarmSolution.psm1 -Destination "$modulePath\xSharePointAdministration\DSCResources\ALIS_xFarmSolution\ALIS_xFarmSolution.psm1" -Force

# Create List Resource
$Url         = New-xDscResourceProperty -Name Url -Type String -Attribute Key -Description "The absolute url of the list (i.e. http://localhost/web/lists/List1)."
$Ensure      = New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -ValidateSet @("Present", "Absent")
$Title       = New-xDscResourceProperty -Name Title -Type String -Attribute Write -Description "The title of the list."
$Description = New-xDscResourceProperty -Name Description -Type String -Attribute Write
$TemplateId  = New-xDscResourceProperty -Name TemplateId -Type String -Attribute Write
$FeatureId   = New-xDscResourceProperty -Name FeatureId -Type String -Attribute Write
$DocTemplate = New-xDscResourceProperty -Name DocTemplateType -Type String -Attribute Write

New-xDscResource -Name ALIS_xList -FriendlyName List -ModuleName xSharePointAdministration -Property @($Url, $Ensure, $Title, $Description, $TemplateId, $FeatureId, $DocTemplate) -Path $modulePath

Copy-Item .\DSCResources\ALIS_xList.psm1 "$modulePath\xSharePointAdministration\DSCResources\ALIS_xList\ALIS_xList.psm1" -force


# Create Feature Resource
$ID      = New-xDscResourceProperty -Name ID      -Type String  -Attribute Key      -Description "The ID of the feature."
$Ensure  = New-xDscResourceProperty -Name Ensure  -Type String  -Attribute Write    -ValidateSet @("Present", "Absent") -Description "Set this to 'Present' to ensure that the feature is actived. Set it to 'Absent' to ensure that the feature is deactivated."
$Url     = New-xDscResourceProperty -Name Url     -Type String  -Attribute Required -Description "The url of the corresponding scope to activate the feature." 
$Force   = New-xDscResourceProperty -Name Force   -Type Boolean -Attribute Write    -Description "Set 'Force' to true to force the activation of the feature."  
$Version = New-xDscResourceProperty -Name Version -Type String  -Attribute Read
$Scope  = New-xDscResourceProperty  -Name xScope -Type String  -Attribute Read -ValidateSet @("Web", "Site", "WebApplication", "Farm")

New-xDscResource -Name ALIS_xFeature -FriendlyName Feature -ModuleName xSharePointAdministration -Property @($ID, $Ensure, $Url, $Force, $Version, $Scope) -Path $modulePath

Copy-Item .\DSCResources\ALIS_xFeature.psm1 "$modulePath\xSharePointAdministration\DSCResources\ALIS_xFeature\ALIS_xFeature.psm1" -force

# Create Site Resource
$Url                = New-xDscResourceProperty -Name Url -Type String -Attribute Key -Description "The URL of the site."
$Ensure             = New-xDscResourceProperty -Name Ensure  -Type String  -Attribute Write    -ValidateSet @("Present", "Absent") -Description "Set this to 'Present' to ensure that the site exists. Set it to 'Absent' to ensure that the site is dealeted."
$Owner              = New-xDscResourceProperty -Name OwnerAlias -Type String -Attribute Write
$SiteType           = New-xDscResourceProperty -Name AdministrationSiteType -Type String -Attribute Write -ValidateSet @("None", "TenantAdministration")
$CompatibilityLevel = New-xDscResourceProperty -Name CompatibilityLevel -Type Sint32 -Attribute Write
$ContentDatabase    = New-xDscResourceProperty -Name ContentDatabase -Type String -Attribute Write 
$Description        = New-xDscResourceProperty -Name Description -Type String -Attribute Write
$HostHeader         = New-xDscResourceProperty -Name HostHeaderWebApplication -Type String -Attribute Write
$Language           = New-xDscResourceProperty -Name Language -Type Uint32 -Attribute Write
$Name               = New-xDscResourceProperty -Name Name -Type String -Attribute Write
$QuotaTemplate      = New-xDscResourceProperty -Name QuotaTemplate -Type String -Attribute Write
$SiteSubscription   = New-xDscResourceProperty -Name SiteSubscription -Type String -Attribute Write
$Template           = New-xDscResourceProperty -Name Template -Type String -Attribute Write

New-xDscResource -Name ALIS_xSite -FriendlyName Site -ModuleName xSharePointAdministration -Property @($Url, $Ensure, $Owner, $SiteType, $CompatibilityLevel, $ContentDatabase, $Description, $HostHeader, $Language, $Name, $QuotaTemplate, $SiteSubscription, $Template) -Path $modulePath

Copy-Item .\DSCResources\ALIS_xSite.psm1 "$modulePath\xSharePointAdministration\DSCResources\ALIS_xSite\ALIS_xSite.psm1"

# Create Web Resource
$Url                = New-xDscResourceProperty -Name Url -Type String -Attribute Key -Description "The URL of the web site."
$Ensure             = New-xDscResourceProperty -Name Ensure  -Type String  -Attribute Write    -ValidateSet @("Present", "Absent") -Description "Set this to 'Present' to ensure that the web site exists. Set it to 'Absent' to ensure that the web site is dealeted."
$Description        = New-xDscResourceProperty -Name Description -Type String -Attribute Write
$Language           = New-xDscResourceProperty -Name Language -Type Uint32 -Attribute Write
$Name               = New-xDscResourceProperty -Name Name -Type String -Attribute Write
$Template           = New-xDscResourceProperty -Name Template -Type String -Attribute Write
$UniquePermissions  = New-xDscResourceProperty -Name UniquePermissions -Type Boolean -Attribute Write
$UseParentTopNav    = New-xDscResourceProperty -Name UseParentTopNav -Type Boolean -Attribute Write
$AddToQuickLaunch   = New-xDscResourceProperty -Name AddToQuickLaunch -Type Boolean -Attribute Write
$AddToTopNav        = New-xDscResourceProperty -Name AddToTopNav -Type Boolean -Attribute Write

New-xDscResource -Name ALIS_xWeb -FriendlyName Web -ModuleName xSharePointAdministration -Property @($Url, $Ensure, $Description, $Name, $Language, $Template, $UniquePermissions, $UseParentTopNav, $AddToQuickLaunch, $AddToTopNav) -Path $modulePath

Copy-Item .\DSCResources\ALIS_xWeb.psm1 "$modulePath\xSharePointAdministration\DSCResources\ALIS_xWeb\ALIS_xWeb.psm1"

Get-DscResource -Name FarmSolution
Get-DscResource -Name List 
Get-DscResource -Name Feature
Get-DscResource -Name Site
Get-DscResource -Name Web

copy-item .\xSharePointAdministration.psd1 "$modulePath\xSharePointAdministration\xSharePointAdministration.psd1"