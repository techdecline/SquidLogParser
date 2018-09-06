# Implement your module commands in this script.


#region HelperFunctions
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
function Resolve-SLPSourceIp {
    param (
        [String]$Line
    )

    return "Not yet implemented"
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
    [CmdletBinding()]
    param (
        # This parameter contains a line that needs to be parsed
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]$LogFileLine,

        # This parameter contains the needed information. If not set, cmdlet will return all properties
        [Parameter(Mandatory=$false)]
        [ValidateSet("TargetUrl","SourceIp")]
        [String[]]$Property
    )

    process {
        $returnObj = 1 | Select-Object -Property $Property
        foreach ($prop in $Property) {
            switch ($prop) {
                "TargetUrl" {
                    $returnObj.TargetUrl = Resolve-SLPTargetUrl -Line $LogFileLine
                }
                "SourceIp" {
                    $returnObj.SourceIp = Resolve-SLPSourceIp -Line $LogFileLine
                }
                # Other properties not yet implemented
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