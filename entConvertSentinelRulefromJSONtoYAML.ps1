# Script by Mr O - Entellectual Services Limited

param (
    [Parameter(Mandatory=$false)]$PathToFiles = ('C:\temp\bulk_rules\*'),
    [Parameter(Mandatory=$false)]$OutputPath = ('C:\temp\bulk_rules\')
)

$files = Get-ChildItem -path $PathToFiles -File -Include *.json
foreach($file in $files) {
    if (Test-Path $file) {
    $data = Get-Content $file | convertfrom-json
    foreach ($convertfile in $data.resources) {
        write-verbose ('Converting ' + $convertfile.properties.displayname) 
        $workspace_item = [ordered]@{}
        $workspace_item['$schema'] = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
        $workspace_item['contentVersion'] = '1.0.0.0'
        $workspace_item["parameters"] = @{}
        $workspace_item["parameters"]["workspace"] = @{}
        $workspace_item["parameters"]["workspace"]['type']= "String"
        $workspace_item["resources"] = @($convertfile)
        $workspace_item | ConvertTo-yaml  | Out-File -filepath "$($OutputPath + ($($convertfile.properties.displayname) -replace '[\W]','_'))_ARM.yml"
        $workspace_item = [ordered]@{}
     }
    }
}

