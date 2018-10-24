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
<#
.Synopsis
   This Function parses a squid access log file line item and returns an object.
.DESCRIPTION
   This Function parses a squid access log file line item and returns an object.

   The return object will contain either all properties or only the ones that are selected using a parameter.
.EXAMPLE$LO

   Resolve-SLPLogItem -LogFileLine "1536154946.720 126553 192.168.0.107 TCP_TUNNEL/200 8441 CONNECT cdn.onenote.net:443 - HIER_DIRECT/104.103.107.203 -" -AllProperties

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