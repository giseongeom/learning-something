# https://stackoverflow.com/questions/10781697/convert-unix-time-with-powershell
# https://stackoverflow.com/questions/23062515/do-unix-timestamps-change-across-timezones

Function ConvertFrom-UnixTime {
    [cmdletbinding()]
    [OutputType([datetime])]
    Param(
        [parameter(ValueFromPipeline)]
        [int64]$unixtime
    )
    Process {
        [datetime]$origin = (Get-Date -Date '01/01/1970 00:00:00Z')
        $origin.AddSeconds($unixtime).ToLocalTime()
    }
}

Function ConvertFrom-UnixTimeMillisecond {
    [cmdletbinding()]
    [OutputType([datetime])]
    Param(
        [parameter(ValueFromPipeline)]
        $unixtime
    )
    Process {
        [datetime]$origin = (Get-Date -Date '01/01/1970 00:00:00Z')
        $origin.AddMilliseconds($unixtime).ToLocalTime()
    }
}

Function ConvertTo-UnixTime {
    [cmdletbinding()]
    Param(
        [parameter(ValueFromPipeline)]
        $Date
    )
    Process {
        [int](New-TimeSpan -Start (Get-Date -Date '01/01/1970') -End ($Date).ToUniversalTime()).TotalSeconds
    }
}


# https://www.powershellgallery.com/packages/Influx/1.0.98
Function ConvertTo-UnixTimeMillisecond {
    <#
        .SYNOPSIS
            Converts a datetime string to a Unix time code in milliseconds.

        .DESCRIPTION
            This is the datetime format Influx expects by default for writing datetime fields.

        .PARAMETER Date
            The date/time to be converted.

        .EXAMPLE
            '01-01-2017 12:34:22.12' | ConvertTo-UnixTimeMillisecond

            Result
            -----------
            1483274062120
    #>
    [cmdletbinding()]
    [OutputType([double])]
    Param(
        [parameter(ValueFromPipeline)]
        $Date
    )
    Process {
        (New-TimeSpan -Start (Get-Date -Date '01/01/1970') -End $Date.ToUniversalTime()).TotalMilliseconds
    }
}


# https://www.powershellgallery.com/packages/Influx/1.0.98
Function ConvertTo-UnixTimeNanosecond {
    <#
        .SYNOPSIS
            Converts a datetime object to a Unix time code in nanoseconds.

        .DESCRIPTION
            This is the datetime format Influx expects for writing the (optional) timestamp field.

        .PARAMETER Date
            The date/time to be converted.

        .EXAMPLE
            '01-01-2017 12:34:22.12' | ConvertTo-UnixTimeNanosecond

            Result
            -------------------
            1483274062120000000
    #>
    [cmdletbinding()]
    [OutputType([long])]
    Param(
        [parameter(ValueFromPipeline)]
        [datetime]
        $Date
    )
    Process {
        [long]((New-TimeSpan -Start (Get-Date -Date '1970-01-01') -End (($Date).ToUniversalTime())).TotalSeconds * 1E9)
    }
}