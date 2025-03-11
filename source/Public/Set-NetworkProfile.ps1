Function Set-NetworkProfile {
    <#
    .SYNOPSIS
    Function to change the name, description or category of existing network profiles in registry
    .DESCRIPTION
    Function takes the unique ProfileName, GUID, or pipeline input of an existing network profile from registry and allows for updating the description, name and/or category  of that profile.
    .PARAMETER ProfileName
    ProfileName to target for updating. Accepts pipeline input.
    .PARAMETER GUID
    Specify the GUID without braces for the network profile. Accepts pipeline input from Get-NetworkProfile
    .PARAMETER NewProfileName
    Specify the new profile name to change the network profile to
    .PARAMETER Description
    Change the description text for the network profile
    .PARAMETER Category
    Change the category for the network profile. Options are Private, Public or Domain
    .NOTES
    Version:        1.0
    Author:         C. Bodett
    Creation Date:  7/16/2024
    Purpose/Change: initial script development
    #>
    #Requires -RunAsAdministrator
    [CmdletBinding(DefaultParameterSetName="ProfileName")]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="ProfileName")]
        [Alias("Name")]
        [Regex]$ProfileName,
        [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="GUID")]
        [guid]$GUID,
        [Parameter(ParameterSetName="ProfileName")]
        [Parameter(ParameterSetName="GUID")]
        [String]$NewProfileName,
        [Parameter(ParameterSetName="ProfileName")]
        [Parameter(ParameterSetName="GUID")]
        [String]$Description,
        [Parameter(ParameterSetName="ProfileName")]
        [Parameter(ParameterSetName="GUID")]
        [ValidateSet("Private","Public","Domain")]
        [String]$Category
    )

    begin {
        $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"
    }

    process {
        switch ($PSBoundParameters.Keys) {
            "GUID" {
                $ProfilePath = Join-Path -Path $RegPath -ChildPath "{$($GUID.ToString())}"
                if (Test-Path $ProfilePath) {
                    $NetworkProfile = Get-NetworkProfile -GUID $GUID
                } else {
                    Write-Warning "No network profile with GUID $GUID found"
                }
            }
            "ProfileName" {
                $NetworkProfile = Get-NetworkProfile -ProfileName $ProfileName
                $ProfilePath = Join-Path -Path $RegPath -ChildPath "{$($NetworkProfile.GUID)}"
                if ($NetworkProfile.count -gt 1) {
                    Write-Warning "Multiple network profiles match the name $ProfileName . Please use the -GUID parameter to specify a single network profile or find a more specific name."
                    $NetworkProfile = $null
                } elseif ($null -eq $NetworkProfile) {
                    Write-Warning "No network profile with name $ProfileName found"
                }                
            }
        }  
        
        if ($NetworkProfile) {
            Write-Verbose "Updating properties on ProfileName: $($NetworkProfile.ProfileName)"
            $ValuesToSet = switch ($PSBoundParameters.Keys) {
                "NewProfileName" {
                    [PSCustomObject]@{
                        Name = "ProfileName"
                        Value = $NewProfileName
                    }
                }
                "Description" {
                    [PSCustomObject]@{
                        Name = "Description"
                        Value = $Description
                    }
                }
                "Category" {
                    [PSCustomObject]@{
                        Name = "Category"
                        Value = switch ($Category) {
                            "Public" {0}
                            "Private" {1}
                            "Domain" {2}
                        }
                    }
                }
            }

            try {
                $ValuesToSet | Set-ItemProperty -Path $ProfilePath -Name {$_.Name} -ErrorAction Stop
            } catch {
                throw $Error[0]
            }
        }
    }

    end {}
}