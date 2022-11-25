# Script by Mr O - Entellectual Services Limited

param (
    [Parameter(Mandatory = $false)]$PathToFiles = ('C:\temp\bulk_rules\'),
    [Parameter(Mandatory = $false)]$OutputPath = ('C:\temp\bulk_rules\')
)


if (!(Test-Path -Path ($PathToFiles))) {
    write-host  "Error:  PAth to files doesnt exist!" -ForegroundColor Red
}

if (!(Test-Path -Path ($OutputPath))) {
    write-host "Output path doesnt existing, creating..." -ForegroundColor yellow 
    new-item -itemType "directory" -path $OutputPath
}

$files = Get-ChildItem -path $($PathToFiles + "/*") -File -Include *.json
foreach ($file in $files) {
    if (Test-Path $file) {
        $data = Get-Content $file | convertfrom-json
        foreach ($convertfile in $data.resources) {
            write-host ('Converting ' + $convertfile.properties.displayname) -ForegroundColor Green 
            $workspace_item = [ordered]@{}
            $workspace_item['$schema'] = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
            $workspace_item['contentVersion'] = '1.0.0.0'
            $workspace_item["parameters"] = @{}
            $workspace_item["parameters"]["workspace"] = @{}
            $workspace_item["parameters"]["workspace"]['type'] = "String"
            if ($convertfile.properties.query) {
                #Clean up the query format
                Write-Verbose "Cleaning up the Query format!"
                $convertfile.properties.query = $convertfile.properties.query -replace "\\n", "`n" -replace '\\"', '"' -replace "`n", "`t`n" -replace "`r", "`t"
            }
            $workspace_item["resources"] = @($convertfile)
            $workspace_item | ConvertTo-yaml  | Out-File -filepath "$($OutputPath + ($($convertfile.properties.displayname) -replace '[\W]','_')).yml"
            $workspace_item = [ordered]@{}
        }
    }
}

