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

& $python main.py
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Done. Personal IPTV files:"
Write-Host "  output/my_iptv.txt"
Write-Host "  output/my_iptv.m3u"
Write-Host ""
Write-Host "If the service is enabled, open:"
Write-Host "  http://127.0.0.1:5180/txt"
Write-Host "  http://127.0.0.1:5180/m3u"
