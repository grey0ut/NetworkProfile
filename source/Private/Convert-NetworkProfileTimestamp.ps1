Function Convert-NetworkProfileTimestamp {
    <#
    .SYNOPSIS
    Convert binary time data from Network Profile registry keys to datetime object
    .DESCRIPTION
    Network Profiles are stored in the registry and two timestamp values stored in binary.  This function will convert those timestamps to a datetime object.
    .PARAMETER RegTimeStamp
    The binary array representing a timestamp
    .EXAMPLE
    Convert-NetworkProfileTimestamp -RegTimeStamp $Profile.GetValue("DateCreated")
    #>
    Param (
        [Byte[]]$RegTimeStamp
    )

    $First = 1
    $Second = 0
    $Values = while ($First -lt 15) {
        if ($First -eq 5) {
            #the bytes in the 4th and 5th are the day of the week which we don't need
        } else {
            [uint32]$('0x{0:x}{1:x}' -f $RegTimeStamp[$First], $RegTimeStamp[$Second])
        }
        $First+=2
        $Second+=2
    }
    New-Object Datetime ($Values)
}