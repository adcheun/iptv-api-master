param(
    [Parameter(Mandatory = $true)][string]$Channel,
    [Parameter(Mandatory = $true)][string]$Url,
    [switch]$Whitelist
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Set-Location (Split-Path -Parent $PSScriptRoot)

$target = "config/local/my_channels.txt"
if (-not (Test-Path "config/local")) {
    New-Item -ItemType Directory -Path "config/local" | Out-Null
}

if (-not (Test-Path $target)) {
    Copy-Item "config/local/my_channels.example.txt" $target
}

$lineUrl = $Url
if ($Whitelist -and -not $lineUrl.EndsWith('$!')) {
    $lineUrl = "$lineUrl`$!"
}

$line = "$Channel,$lineUrl"
Add-Content -Path $target -Value $line -Encoding UTF8

Write-Host "Added:"
Write-Host "  $line"
Write-Host ""
Write-Host "Next:"
Write-Host "  .\scripts\update-personal-conda.ps1"
