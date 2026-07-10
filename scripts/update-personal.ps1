$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Set-Location (Split-Path -Parent $PSScriptRoot)

$python = Get-Command python -ErrorAction SilentlyContinue
$pyLauncher = Get-Command py -ErrorAction SilentlyContinue

if ($pyLauncher) {
    $pyCheck = & py -3.13 --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $env:PIPENV_PYTHON = "3.13"
    }
}

if (-not $env:PIPENV_PYTHON -and $python) {
    $pythonCheck = & python --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $env:PIPENV_PYTHON = (Get-Command python).Source
    }
}

if (-not $env:PIPENV_PYTHON) {
    Write-Error "Python is not installed or not available in PATH. Install Python 3.13 from https://www.python.org/downloads/ and tick 'Add python.exe to PATH'."
}

if (-not (Get-Command pipenv -ErrorAction SilentlyContinue)) {
    if ($env:PIPENV_PYTHON -eq "3.13") {
        py -3.13 -m pip install --user pipenv
    } else {
        & $env:PIPENV_PYTHON -m pip install --user pipenv
    }
}

pipenv --python $env:PIPENV_PYTHON
pipenv install --deploy
pipenv run dev

Write-Host ""
Write-Host "Done. Personal IPTV files:"
Write-Host "  output/my_iptv.txt"
Write-Host "  output/my_iptv.m3u"
Write-Host ""
Write-Host "If the service is enabled, open:"
Write-Host "  http://127.0.0.1:5180/txt"
Write-Host "  http://127.0.0.1:5180/m3u"
