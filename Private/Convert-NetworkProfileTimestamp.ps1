Function Convert-NetworkProfileTimestamp {
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