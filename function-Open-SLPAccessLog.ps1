<#
.Synopsis
   This Function opens a Squid Log File.
.DESCRIPTION
   This Function opens a Squid Log File and return an Array List.

   If the selected file cannot be openend the function returns a null value.
.EXAMPLE

   Open-SLPAccessLog -AccessLogFilePath "C:\Squid\var\log\squid\access.log"

   This call will open a log file stored at "C:\Squid\var\log\squid\access.log"
#>
function Open-SLPAccessLog {
    [CmdletBinding()]
    [outputtype([System.Object[]])]
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