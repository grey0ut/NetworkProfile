Function Get-NetworkProfile {
    <#
    .SYNOPSIS
    Function to return network profiles from registry as Powershell objects
    .DESCRIPTION
    Query the Local Machine registry hive for current network profiles and return them as Powershell objects. Requires administrative privilege to read the hive.
    .PARAMETER ProfileName
    Return a specific network profile by name. Uses regex for matching. 
    .NOTES
    Version:        1.0
    Author:         C. Bodett
    Creation Date:  7/16/2024
    Purpose/Change: initial script development
    #>
    #Requires -RunAsAdministrator
    [CmdletBinding(DefaultParameterSetName="none")]
    Param (
        [Parameter(Mandatory=$false,Position=0,ParameterSetName="ProfileName")]
        [Alias("Name")]
        [Regex]$ProfileName,
        [Parameter(Mandatory=$false,Position=1,ParameterSetName="GUID")]
        [Guid]$GUID
    )

    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"

    $RegProfiles = switch ($PSCmdlet.ParameterSetName) {
        "ProfileName" {
            try {
                Get-ChildItem $RegPath -ErrorAction Stop | Where-Object {
                    $_.GetValue("ProfileName") -match $ProfileName.ToString()
                }
            } catch {
                throw $Error[0]
            }
        }
        "GUID" {
            try {
                $ProfilePath = Join-Path -Path $RegPath -ChildPath "{$($GUID.ToString())}"
                if (Test-Path $ProfilePath) {
                   Get-Item -Path $ProfilePath 
                } else {
                    Write-Warning "No network profile found matching GUID: {$($GUID.ToString())}"
                }
            } catch {
                throw $Error[0]
            }
        }
        "none" {
            try {
                Get-ChildItem $RegPath -ErrorAction Stop
            } catch {
                throw $Error[0]
            }
        }
    }

    Foreach ($Profile in $RegProfiles) {
        $Managed = Get-ItemPropertyValue -Path $(Join-Path -Path $RegPath -ChildPath $Profile.PSChildName) -Name "Managed" | Foreach-Object {
            if ($_ -eq 1) {
                "Yes"
            } else {
                "No"
            }
        }
        $Category = Get-ItemPropertyValue -Path $(Join-Path -Path $RegPath -ChildPath $Profile.PSChildName) -Name "Category" | Foreach-Object {
            switch ($_) {
                0 {"Public"}
                1 {"Private"}
                2 {"Domain"}
            }
        }
        $DateCreated = Convert-NetworkProfileTimestamp -RegTimeStamp $Profile.GetValue("DateCreated")
        $NameTypeValue = Get-ItemPropertyValue -Path $(Join-Path -Path $RegPath -ChildPath $Profile.PSChildName) -Name "NameType" | Foreach-Object {
            switch ($_) {
                6  {"Wired Network"}
                23  {"VPN"}
                71  {"Wireless Network"}
                243  {"Mobile Broadband"}
            }
        }
        $DateLastConnected = Convert-NetworkProfileTimestamp -RegTimeStamp $Profile.GetValue("DateLastConnected")
        [PSCustomObject]@{
            PSTypeName          = "NetworkProfile"
            ProfileName         = $Profile.GetValue("ProfileName")
            Description         = $Profile.GetValue("Description")
            Managed             = $Managed
            Category            = $Category
            DateCreated         = $DateCreated
            NameType            = $NameTypeValue
            DateLastConnected   = $DateLastConnected
            GUID                = [GUID]$Profile.PSChildName
        }
    }
}