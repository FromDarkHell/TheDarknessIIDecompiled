Get-ChildItem -Path ..\ -Filter *.lua -Recurse -File -Name| ForEach-Object {
    $OutputName = "Decompile\" + $_
    $InputName = "..\" + $_
    $OutputDir = [System.IO.Path]::GetDirectoryName($OutputName)
    New-Item -Path $OutputDir -ItemType Directory -Force | out-null 
    Write-Host $OutputName
    java -jar unluac.jar $InputName > $OutputName
}