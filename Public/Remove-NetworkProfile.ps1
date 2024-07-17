Function Remove-NetworkProfile {
    <#
    .SYNOPSIS
    Function to change the name, description or category of existing network profiles in registry
    .DESCRIPTION
    Function takes the unique ProfileName, GUID, or pipeline input of an existing network profile from registry and allows for updating the description, name and/or category  of that profile.
    .PARAMETER ProfileName
    ProfileName to target for updating. Accepts pipeline input.
    .PARAMETER GUID
    Specify the GUID without braces for the network profile. Accepts pipeline input from Get-NetworkProfile
    .NOTES
    Version:        1.0
    Author:         C. Bodett
    Creation Date:  7/16/2024
    Purpose/Change: initial script development
    #>
    #Requires -RunAsAdministrator
    [CmdletBinding(DefaultParameterSetName="ProfileName",SupportsShouldProcess,ConfirmImpact="High")]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="ProfileName")]
        [Alias("Name")]
        [Regex]$ProfileName,
        [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="GUID")]
        [guid]$GUID
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
            Write-Verbose "Removing network profile: $($NetworkProfile.ProfileName) / $($NetworkProfile.GUID.ToString())"
            if ($PSCmdlet.ShouldProcess($ProfilePath,'Remove-Item')) {
                try {
                    Remove-Item -Path $ProfilePath
                } catch {
                    $Error[0]
                }
            }
        }
    }

    end {}
}