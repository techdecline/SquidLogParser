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
<#
.Synopsis
   This Function opens a Squid Log File.
.DESCRIPTION
   This Function opens a Squid Log File and return an Array List.

   If the selected file cannot be openend the function returns a null value.
.EXAMPLE

   Open-SLPAccessLog -AccessLogFilePath C:\squid\var\log\access.log

   This call will open a log file stored at "C:\squid\var\log\access.log"
#>
function Open-SLPAccessLog {
    [CmdletBinding()]
    param (
        # This parameter contains the path to a Squid Access Log File
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateScript({Test-Path $_})]
        [String]$AccessLogFilePath
    )

    process {
        try {
            $squidLogObj = Get-Content $AccessLogFilePath -ErrorAction Stop
            return $squidLogObj
        }
        catch [System.Management.Automation.ActionPreferenceStopException] {
            Write-Error "Could not open Log File"
            return $null
        }
    }
}

<#
.Synopsis
   This Function parses a squid access log file line item and returns an object.
.DESCRIPTION
   This Function parses a squid access log file line item and returns an object.

   The return object will contain either all properties or only the ones that are selected using a parameter.
.EXAMPLE

   Resolve-SLPLogItem -LogFileLine "1536154946.720 126553 192.168.0.107 TCP_TUNNEL/200 8441 CONNECT cdn.onenote.net:443 - HIER_DIRECT/104.103.107.203 -"

   This call will return an object containing all attributes.

.EXAMPLE

Resolve-SLPLogItem -LogFileLine "1536154946.720 126553 192.168.0.107 TCP_TUNNEL/200 8441 CONNECT cdn.onenote.net:443 - HIER_DIRECT/104.103.107.203 -" -Property TargetUrl

This call will return an object containing only the target URL.
#>
function Resolve-SLPLogItem {
    [CmdletBinding(DefaultParameterSetName="BySelectedProperties")]
    param (
        # This parameter contains a line that needs to be parsed
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]$LogFileLine,

        # This parameter contains the needed properties
        [Parameter(Mandatory,ParameterSetName="BySelectedProperties")]
        [PropertyList[]]$Property,

        # This parameter indicates taht all properties shall be returned
        [Parameter(Mandatory=$false,ParameterSetName="ByAllProperties")]
        [switch]$AllProperties
    )

    process {
        if ($AllProperties) {
            $propertyList = [PropertyList].GetEnumNames()
        }
        else {
            $propertyList = [String[]]$Property
        }

        $returnObj = 1 | Select-Object -Property $propertyList

        foreach ($prop in $propertyList) {
            switch ($prop) {
                "TargetUrl" {
                    $returnObj.TargetUrl = Resolve-SLPTargetUrl -Line $LogFileLine
                }
                "ClientAddress" {
                    $returnObj.ClientAddress = Resolve-SLPClientAddress -Line $LogFileLine
                }
                "DateTime" {
                    $returnObj.DateTime = Resolve-SLPDateTime -Line $LogFileLine
                }
                "Duration" {
                    $returnObj.Duration = Resolve-SLPDuration -Line $LogFileLine
                }
                "ReturnCode" {
                    $returnObj.ReturnCode = Resolve-SLPReturnCode -Line $LogFileLine
                }
                "SizeBytes" {
                    $returnObj.SizeBytes = Resolve-SLPSizeBytes -Line $LogFileLine
                }
                "RequestMode" {
                    $returnObj.RequestMode = Resolve-SLPRequestMode -Line $LogFileLine
                }
                "User" {
                    $returnObj.User = Resolve-SLPUser -Line $LogFileLine
                }
                "HierarchyCode" {
                    $returnObj.HierarchyCode = Resolve-SLPHierarchyCode -Line $LogFileLine
                }
                "Type" {
                    $returnObj.Type = Resolve-SLPType -Line $LogFileLine
                }
            }
        }
        return $returnObj
    }
}


#endregion

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Resolve-SLPLogItem,Open-SLPAccessLog