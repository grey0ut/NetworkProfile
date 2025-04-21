Function Get-NetworkProfile {
    <#
    .SYNOPSIS
    Function to return network profiles from registry as Powershell objects
    .DESCRIPTION
    Query the Local Machine registry hive for current network profiles and return them as Powershell objects. Requires administrative privilege to read the hive.
    .PARAMETER ProfileName
    Return a specific network profile by name. Uses regex for matching. 
    .PARAMETER GUID
    Return a specific network profile by GUID.  If you run Get-NetworkProfile with no arguments, the returned objects have a property called 'GUID' that's not shown in the table format view.
    Either pipe the output to `select *` or `format-list` to view the GUIDs.  Can also be seen if capturing the output in a variable and then calling the property.
    .EXAMPLE
    PS> Get-NetworkProfile

    ProfileName Description  Managed Category DateCreated          NameType         DateLastConnected    
    ----------- -----------  ------- -------- -----------          --------         -----------------    
    PSHSummit   PSHSummit    No      Public   4/8/2024 8:58:09 AM  Wireless Network 4/10/2024 12:58:16 PM
    Gizmo       Network      No      Public   7/16/2024 3:23:27 PM Wireless Network 7/16/2024 4:09:02 PM
    contoso     contoso.lcl  Yes     Domain   1/31/2024 5:28:46 PM Wired Network    7/16/2024 3:25:07 PM

    # with no arguments it returns all network profiles found in the registry
    .EXAMPLE
    PS> $Profile = Get-NetworkProfile -ProfileName PSHSummit
    PS> $Profile | Format-List  
    
    ProfileName       : PSHSummit
    Description       : PSHSummit
    Managed           : No
    Category          : Public
    DateCreated       : 4/8/2024 8:58:09 AM
    NameType          : Wireless Network
    DateLastConnected : 4/10/2024 12:58:16 PM
    GUID              : 4b2c4e83-90ca-4aa4-a321-2a7b08d3d669  
    
    # now with the GUID property we can use it to retrieve that specific profile.
    PS> Get-NetworkProfile -GUID 4b2c4e83-90ca-4aa4-a321-2a7b08d3d669 

    ProfileName Description  Managed Category DateCreated          NameType         DateLastConnected    
    ----------- -----------  ------- -------- -----------          --------         -----------------    
    PSHSummit   PSHSummit    No      Public   4/8/2024 8:58:09 AM  Wireless Network 4/10/2024 12:58:16 PM
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
                53 {"VPN"}
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