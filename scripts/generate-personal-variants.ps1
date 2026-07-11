$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Set-Location (Split-Path -Parent $PSScriptRoot)
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

$candidates = @(
    (Join-Path $PWD ".venv314\Scripts\python.exe"),
    (Join-Path $PWD ".venv\Scripts\python.exe"),
    "$env:CONDA_PREFIX\python.exe",
    "$env:USERPROFILE\anaconda3\python.exe",
    "$env:USERPROFILE\miniconda3\python.exe",
    "C:\ProgramData\anaconda3\python.exe",
    "C:\ProgramData\miniconda3\python.exe",
    "python"
) | Where-Object { $_ -and ((Test-Path $_) -or (Get-Command $_ -ErrorAction SilentlyContinue)) }

if (-not $candidates -or $candidates.Count -eq 0) {
    Write-Error "Could not find python.exe. Please install Python 3.13+ or create .venv314 first."
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

Invoke-IPTVBuild -Name "Default public playlist" -Env @{
    "FINAL_FILE" = "output/my_iptv.txt"
    "UPDATE_INTERVAL" = "0"
    "IPV6_SUPPORT" = "False"
    "IPV_TYPE" = "all"
    "IPV_TYPE_PREFER" = "ipv4,ipv6"
    "ORIGIN_TYPE_PREFER" = "subscribe,local"
    "LOCAL_NUM" = "3"
    "SUBSCRIBE_NUM" = "5"
    "MIN_RESOLUTION" = "1280x720"
    "MIN_SPEED" = "0.35"
    "RESOLUTION_SPEED_MAP" = "1280x720:0.2,1920x1080:0.45,3840x2160:1.0"
    "URLS_LIMIT" = "5"
    "OPEN_SUPPLY" = "True"
}

Invoke-IPTVBuild -Name "IPv4 stable" -Env @{
    "FINAL_FILE" = "output/my_iptv_ipv4.txt"
    "UPDATE_INTERVAL" = "0"
    "IPV6_SUPPORT" = "False"
    "IPV_TYPE" = "ipv4"
    "IPV_TYPE_PREFER" = "ipv4"
    "ORIGIN_TYPE_PREFER" = "subscribe,local"
    "LOCAL_NUM" = "3"
    "SUBSCRIBE_NUM" = "5"
    "MIN_RESOLUTION" = "1280x720"
    "MIN_SPEED" = "0.35"
    "RESOLUTION_SPEED_MAP" = "1280x720:0.2,1920x1080:0.45,3840x2160:1.0"
    "URLS_LIMIT" = "3"
    "OPEN_SUPPLY" = "True"
}

Invoke-IPTVBuild -Name "IPv6 playlist" -Env @{
    "FINAL_FILE" = "output/my_iptv_ipv6_hd.txt"
    "UPDATE_INTERVAL" = "0"
    "IPV6_SUPPORT" = "True"
    "IPV_TYPE" = "ipv6"
    "IPV_TYPE_PREFER" = "ipv6"
    "ORIGIN_TYPE_PREFER" = "subscribe,local"
    "LOCAL_NUM" = "3"
    "SUBSCRIBE_NUM" = "5"
    "MIN_RESOLUTION" = "1280x720"
    "MIN_SPEED" = "0.3"
    "RESOLUTION_SPEED_MAP" = "1280x720:0.2,1920x1080:0.5,3840x2160:1.0"
    "URLS_LIMIT" = "3"
    "OPEN_SUPPLY" = "True"
}

& $python scripts/normalize-playlist-outputs.py
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Done. Variant files:"
Write-Host "  output/my_iptv.txt"
Write-Host "  output/my_iptv.m3u"
Write-Host "  output/my_iptv_ipv4.txt"
Write-Host "  output/my_iptv_ipv4.m3u"
Write-Host "  output/my_iptv_ipv6_hd.txt"
Write-Host "  output/my_iptv_ipv6_hd.m3u"
Write-Host "  output/result.txt"
Write-Host "  output/result.m3u"
Write-Host "  output/ipv4/result.txt"
Write-Host "  output/ipv4/result.m3u"
Write-Host "  output/ipv6/result.txt"
Write-Host "  output/ipv6/result.m3u"
