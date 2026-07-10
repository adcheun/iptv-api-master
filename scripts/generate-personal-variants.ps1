$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Set-Location (Split-Path -Parent $PSScriptRoot)
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

$candidates = @(@(
    "$env:CONDA_PREFIX\python.exe",
    "$env:USERPROFILE\anaconda3\python.exe",
    "$env:USERPROFILE\miniconda3\python.exe",
    "C:\ProgramData\anaconda3\python.exe",
    "C:\ProgramData\miniconda3\python.exe"
) | Where-Object { $_ -and (Test-Path $_) })

if (-not $candidates -or $candidates.Count -eq 0) {
    Write-Error "Could not find Anaconda/Miniconda python.exe. Please check your Anaconda install path."
}

$python = $candidates[0]
Write-Host "Using Python: $python"
& $python --version

& $python -m pip install -r requirements-personal.txt
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

function Invoke-IPTVBuild {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][hashtable]$Env
    )

    Write-Host ""
    Write-Host "=============================="
    Write-Host "Generating: $Name"
    Write-Host "=============================="

    $backup = @{}
    foreach ($key in $Env.Keys) {
        $backup[$key] = [Environment]::GetEnvironmentVariable($key, "Process")
        [Environment]::SetEnvironmentVariable($key, [string]$Env[$key], "Process")
    }

    try {
        & $python main.py
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    } finally {
        foreach ($key in $Env.Keys) {
            [Environment]::SetEnvironmentVariable($key, $backup[$key], "Process")
        }
    }
}

Invoke-IPTVBuild -Name "IPv4 stable" -Env @{
    "FINAL_FILE" = "output/my_iptv_ipv4.txt"
    "UPDATE_INTERVAL" = "0"
    "IPV6_SUPPORT" = "False"
    "IPV_TYPE" = "ipv4"
    "IPV_TYPE_PREFER" = "ipv4"
    "MIN_RESOLUTION" = "1280x720"
    "MIN_SPEED" = "0.35"
    "RESOLUTION_SPEED_MAP" = "1280x720:0.2,1920x1080:0.45,3840x2160:1.0"
    "URLS_LIMIT" = "3"
    "OPEN_SUPPLY" = "True"
}

Invoke-IPTVBuild -Name "IPv6 HD" -Env @{
    "FINAL_FILE" = "output/my_iptv_ipv6_hd.txt"
    "UPDATE_INTERVAL" = "0"
    "IPV6_SUPPORT" = "True"
    "IPV_TYPE" = "ipv6"
    "IPV_TYPE_PREFER" = "ipv6"
    "MIN_RESOLUTION" = "1920x1080"
    "MIN_SPEED" = "0.8"
    "RESOLUTION_SPEED_MAP" = "1280x720:0.5,1920x1080:0.8,3840x2160:1.5"
    "URLS_LIMIT" = "3"
    "OPEN_SUPPLY" = "False"
}

Write-Host ""
Write-Host "Done. Variant files:"
Write-Host "  output/my_iptv_ipv4.txt"
Write-Host "  output/my_iptv_ipv4.m3u"
Write-Host "  output/my_iptv_ipv6_hd.txt"
Write-Host "  output/my_iptv_ipv6_hd.m3u"
