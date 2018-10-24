enum PropertyList {
    DateTime
    Duration
    ClientAddress
    ReturnCode
    SizeBytes
    RequestMode
    TargetUrl
    User
    HierarchyCode
    Type
}
# Implement your module commands in this script.

#region HelperFunctions
Function Convert-FromUnixDate ($UnixDate) {
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate))
 }

function Resolve-SLPDateTime {
    param ($Line)

    $str = ($Line -split "\s+")[0]
    $arr = $str -split "\."
    [DateTime]$time = (Convert-FromUnixDate $arr[0]).addmilliseconds($arr[1])
    return $time
}
function Resolve-SLPTargetUrl {
    param (
        [String]$Line
    )

    # Define Regular Expressions for internet ressources
    [regex]$regexHttp = "http.*"
    [regex]$regexPort = " .*:[0-9]{2,5}"

    $match = ($regexHttp.Matches($line)).Value
    $url = ($match -split " ")[0]
    if (-not $url) {
        $match = ($regexPort.Matches($line)).Value
        $url = ($match -split " ")[-1]
    }
    if ($url) {
        return $url
    }
    else {
        return $null
    }
}

function Resolve-SLPClientAddress {
    param (
        [String]$Line
    )

    $ipAddress = ($line -split "\s+")[2]
    return $ipAddress
}

function Resolve-SLPDuration {
    param (
        [String]$Line
    )

    $Duration = ($line -split "\s+")[1]
    return $Duration
}

function Resolve-SLPReturnCode {
    param (
        [String]$Line
    )

    $Duration = ($line -split "\s+")[3]
    return $Duration
}

function Resolve-SLPSizeBytes {
    param (
        [String]$Line
    )

    $SizeBytes = ($line -split "\s+")[4]
    return $SizeBytes
}

function Resolve-SLPRequestMode {
    param (
        [String]$Line
    )

    $RequestMode = ($line -split "\s+")[5]
    return $RequestMode
}

function Resolve-SLPUser  {
    param (
        [String]$Line
    )

    $User = ($line -split "\s+")[7]
    if ($User -ne "-") {
        return $User
    }
    else {
        return $null
    }
}

function Resolve-SLPHierarchyCode {
    param (
        [String]$Line
    )

    $HierarchyCode = ($line -split "\s+")[8]
    return $HierarchyCode
}
function Resolve-SLPType {
    param (
        [String]$Line
    )

    $Type = ($line -split "\s+")[9]
    if ($Type -ne "-") {
        return $Type
    }
    else {
        return $null
    }
}
#endregion

#region ExportedFunctions

. .\function-Open-SLPAccessLog.ps1
. .\function-Resolve-SLPLogItem.ps1

#endregion

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Resolve-SLPLogItem,Open-SLPAccessLog