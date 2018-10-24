$moduleName = "SquidLogParser"
Remove-Module $moduleName -Force -ErrorAction SilentlyContinue

Import-Module "$PSScriptRoot\..\$moduleName.psd1"

Describe "Resolve-SLPLogItem Function Test - All Properties" {
    $logItem = Resolve-SLPLogItem -LogFileLine "1535358035.279  30082 172.17.53.88 TAG_NONE/503 0 CONNECT www.msn.com:443 - HIER_NONE/- -"  -AllProperties

    Context "Log Item has the right properties" {
        $properties = ('DateTime','Duration','ClientAddress','ReturnCode','SizeBytes','RequestMode','TargetUrl','User','HierarchyCode','Type')

        foreach ($property in $properties) {
            It "Log Item should have a property of $property" {
                [bool]($logItem.PSObject.Properties.Name -match $property) | should be $true
            }
        }
    }
}