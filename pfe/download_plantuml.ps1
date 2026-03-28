$ErrorActionPreference = 'Stop'
$uri = 'https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-1.2024.8.jar'
$out = Join-Path $PSScriptRoot ('plantuml-' + [Guid]::NewGuid().ToString('n') + '.jar')
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $uri -OutFile $out -UseBasicParsing
Write-Host "Saved: $out"
Get-Item $out | Select-Object Name, Length
