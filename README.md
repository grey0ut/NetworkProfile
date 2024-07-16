# NetworkProfile

A micro module (Thanks [Kevin](https://powershellexplained.com/2019-04-11-Powershell-Building-Micro-Modules/)) for viewing, and changing some properties of, network connection profiles in Windows registry.

Born of a need  to change a network connection profile from "Public" to "Private" while **not** connected to that network.

# Get-NetworkProfile

function to get all the current network profiles defined in registry.

```Powershell
PS$> Get-NetworkProfile  
  
ProfileName Description  Managed Category DateCreated          NameType         DateLastConnected    
----------- -----------  ------- -------- -----------          --------         -----------------    
PSHSummit   PSHSummit    No      Public   4/8/2024 8:58:09 AM  Wireless Network 4/10/2024 12:58:16 PM
Gizmo       Network      No      Public   7/16/2024 3:23:27 PM Wireless Network 7/16/2024 4:09:02 PM
contoso     contoso.lcl  Yes     Domain   1/31/2024 5:28:46 PM Wired Network    7/16/2024 3:25:07 PM  
  
```

## Parameter ProfileName

Specify the profile name to retrieve from the registry. Regex by default so it supports partial matching.

## Parameter GUID

Specify the GUID (as seen from the Registry) of the network profile you wish to retrieve.  
This property is actually returned by default if you examine one of the output objects, or Format-List. I.e.

```Powershell
PS$> $Profile = Get-NetworkProfile -ProfileName PSHSummit
PS$> $Profile | Format-List  
  
ProfileName       : PSHSummit
Description       : PSHSummit
Managed           : No
Category          : Public
DateCreated       : 4/8/2024 8:58:09 AM
NameType          : Wireless Network
DateLastConnected : 4/10/2024 12:58:16 PM
GUID              : 4b2c4e83-90ca-4aa4-a321-2a7b08d3d669  
```

# Set-NetworkProfile

Allows for changing the ProfileName, Description and/or the Category of an existing network profile.  Accepts pipeline input from Get-NetworkProfile.

```Powershell
PS$> Get-NetworkProfile -ProfileName PSHSummit  

ProfileName Description Managed Category DateCreated         NameType         DateLastConnected
----------- ----------- ------- -------- -----------         --------         -----------------    
PSHSummit   PSHSummit   No      Public   4/8/2024 8:58:09 AM Wireless Network 4/10/2024 12:58:16 PM  
  
PS$> Get-NetworkProfile -ProfileName PSHSummit | Set-NetworkProfile -Description "Powershell Rocks" -Category "Private"
PS$> Get-NetworkProfile -ProfileName PSHSummit  

ProfileName Description      Managed Category DateCreated         NameType         DateLastConnected    
----------- -----------      ------- -------- -----------         --------         -----------------
PSHSummit   Powershell Rocks No      Private  4/8/2024 8:58:09 AM Wireless Network 4/10/2024 12:58:16 PM
```

## Parameter ProfileName

Specify the profile name to up in the registry. Regex by default so it supports partial matching.

## Parameter GUID

Specify the GUID (as seen from the Registry) of the network profile you wish to update.  
This property is actually returned by default if you examine one of the output objects, or Format-List. I.e.

## Parameter NewProfileName

The profile name to set for the existing network profile.  Will be displayed in the usual Windows networking graphical areas

## Parameter Description

The description to update for the specified network profile.

## Parameter Category

Change the category of an existing networking profile to Domain, Public or Private.  The corresponding firewall profile will apply.

# Remove-NetworkProfile

optionally this function will outright delete the entire network profile from registry. Definitely use at your own risk, make registry backups etc.  
Note that this does not touch the signatures portion of the "NetworkList" key.  If you delete a network profile, and the signature remains my limited testing shows that Windows will build a new network profile and update the GUID in the existing network signature to match.

```Powershell
PS$> Get-networkprofile -ProfileName PSHSummit | Remove-NetworkProfile

Confirm
Are you sure you want to perform this action?
Performing the operation "Remove-Item" on target "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\{4b2c4e83-90ca-4aa4-a321-2a7b08d3d669}".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
```