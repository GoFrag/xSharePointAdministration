function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Url
	)

    Ensure-PSSnapin

    $gc = Start-SPAssignment -Verbose:$false

    try
    {
    	$Site = $gc | Get-SPSite $Url -ErrorAction SilentlyContinue -Verbose:$false

        if ($Site -eq $null)
        {
            $result = @{
		        Url = $Url
		        Ensure = "Absent"
	        }
        }
        else
        {

            $contentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService  
            $quotaTemplate = $contentService.QuotaTemplates | where {$_.QuotaID -match $Site.Quota.QuotaID} 

	        $result = @{
		        Url = $Url
		        Ensure = "Present"
		        Owner = $Site.Owner.LoginName
		        AdministrationSiteType = $Site.AdministrationSiteType
		        CompatibilityLevel = $site.CompatibilityLevel
		        ContentDatabase = $site.ContentDatabase.Name
		        Description = $Site.RootWeb.Description
		        HostHeaderWebApplication = $Site.Url
		        Language = $Site.RootWeb.Language
		        Name = $Site.RootWeb.Name
		        QuotaTemplate = $quotaTemplate.Name
		        SiteSubscription = $site.SiteSubscription.Id
		        Template = "$($Site.RootWeb.WebTemplate)#$($Site.RootWeb.WebTemplateId)"
	        }
        }

        $result
    }
    finally
    {
        Stop-SPAssignment $gc -Verbose:$false

        Release-PSSnapin
    }

}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Url,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[System.String]
		$OwnerAlias = $(whoami),

		[ValidateSet("None","TenantAdministration")]
		[System.String]
		$AdministrationSiteType,

		[System.Int32]
		$CompatibilityLevel,

		[System.String]
		$ContentDatabase,

		[System.String]
		$Description,

		[System.String]
		$HostHeaderWebApplication,

		[System.UInt32]
		$Language,

		[System.String]
		$Name,

		[System.String]
		$QuotaTemplate,

		[System.String]
		$SiteSubscription,

		[System.String]
		$Template
	)

	Ensure-PSSnapin

    $gc = Start-SPAssignment -Verbose:$false

    try
    {
        if ($Ensure -eq "Absent")
        {
            Remove-SPSite $Url -AssignmentCollection $gc -Confirm:$false
            Write-Verbose "Site '$Url' successfully deleted."
        }
        else
        {
            $Site = $gc | Get-SPSite $Url -ErrorAction SilentlyContinue -Verbose:$false

            if ($Site -eq $null)
            {
                $PSBoundParameters.Remove("Ensure") | Out-Null
                $PSBoundParameters.Remove("Url") | Out-Null
                $PSBoundParameters.Remove("Debug") | Out-Null
                $PSBoundParameters.Remove("OwnerAlias") | Out-Null
                $PSBoundParameters.Remove("Confirm") | Out-Null

                Write-Verbose "Parameters: $($PSBoundParameters.Keys.ForEach({"-$_ $($PSBoundParameters.$_)"}) -join ' ')"

                New-SPSite $Url -OwnerAlias $OwnerAlias -Confirm:$false -AssignmentCollection $gc @PSBoundParameters

                Write-Verbose "SPSite '$Url' was created successfully."
            }
            else
            {
                if ($QuotaTemplate)
                {
                    Set-SPSite -Identity $Site.url -QuotaTemplate $QuotaTemplate -AssignmentCollection $gc
                    Write-Verbose "The quota template '$QuotaTemplate' was applied to site '$($Site.Url)'."
                }
            }
        }
    }
    finally
    {
        Stop-SPAssignment $gc -Verbose:$false

        Release-PSSnapin
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Url,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure = "Present",

		[System.String]
		$OwnerAlias = $(whoami),

		[ValidateSet("None","TenantAdministration")]
		[System.String]
		$AdministrationSiteType,

		[System.Int32]
		$CompatibilityLevel,

		[System.String]
		$ContentDatabase,

		[System.String]
		$Description,

		[System.String]
		$HostHeaderWebApplication,

		[System.UInt32]
		$Language,

		[System.String]
		$Name,

		[System.String]
		$QuotaTemplate,

		[System.String]
		$SiteSubscription,

		[System.String]
		$Template
	)

	Ensure-PSSnapin

    $gc = Start-SPAssignment -Verbose:$false

    try
    {
    	$Site = $gc | Get-SPSite $Url -ErrorAction SilentlyContinue -Verbose:$false

        if (($Site -eq $null -and $Ensure -eq "Present") -or ($Site -ne $null -and $Ensure -eq "Absent"))
        {
            Write-Verbose "The ensure state does not match the desired state '$Ensure'."
            return $false
        }

        if ($Site -ne $null)
        {
            if ($QuotaTemplate)
            {
                $contentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService  
                $currentQuotaTemplate = $contentService.QuotaTemplates | where {$_.QuotaID -match $Site.Quota.QuotaID} 

                if ($currentQuotaTemplate.Name -ne $QuotaTemplate)
                {
                    Write-Verbose "The quota template '$($currentQuotaTemplate.Name)' does not match the desired state '$QuotaTemplate'."
                    return $false
                }
            }
        }

	    return $true
    }
    finally
    {
        Stop-SPAssignment $gc -Verbose:$false

        Release-PSSnapin
    }
}

function Ensure-PSSnapin
{
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
    {
        Add-PSSnapin "Microsoft.SharePoint.PowerShell" -Verbose:$false
        Write-Verbose "SharePoint Powershell Snapin loaded."
    } 
}

function Release-PSSnapin
{
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -ne $null) 
    {
        Remove-PSSnapin "Microsoft.SharePoint.PowerShell" -Verbose:$false
        Write-Verbose "SharePoint Powershell Snapin removed."
    } 
}

function Throw-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [string]$errorId,
        [string]$errorMessage,
        [System.Management.Automation.ErrorCategory]$errorCategory = [System.Management.Automation.ErrorCategory]::InvalidResult
    )

    $exception = New-Object System.InvalidOperationException $errorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null

    $PSCmdlet.ThrowTerminatingError($errorRecord);
}

Export-ModuleMember -Function *-TargetResource

