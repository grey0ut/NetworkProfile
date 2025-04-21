@{

# Script module or binary module file associated with this manifest.
RootModule = 'NetworkProfile.psm1'

# Version number of this module.
ModuleVersion = '1.4.3'

# Supported PSEditions
CompatiblePSEditions = 'Desktop'

# ID used to uniquely identify this module
GUID = 'aa94b2ff-7604-409a-8bbf-45ce06bac9a8'

# Author of this module
Author = 'Courtney Bodett'

# Company or vendor of this module
CompanyName = 'Grey0ut'

# Copyright statement for this module
Copyright = '(c) 2025 Courtney Bodett. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Manage Network Profile information stored in the registry'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = '.\Formats\NetworkProfile.format.ps1xml'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Get-NetworkProfile', 'Remove-NetworkProfile', 'Set-NetworkProfile'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Network','Wifi','NetworkCategory','NetworkProfile','Windows','PSEdition_Desktop')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/grey0ut/NetworkProfile/blob/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/grey0ut/NetworkProfile'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

