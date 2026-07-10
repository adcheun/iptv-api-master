param(
    [string]$Playlist = "output/my_iptv_ipv4.m3u"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not (Test-Path $Playlist)) {
    Write-Error "Playlist not found: $Playlist"
}

$items = @{}
$currentGroup = ""

foreach ($line in Get-Content -Encoding UTF8 $Playlist) {
    if ($line -notlike "#EXTINF*") {
        continue
    }

    $name = ($line -replace '^.*?,', '').Trim()
    $group = ""
    if ($line -match 'group-title="([^"]+)"') {
        $group = $Matches[1]
    }
    if (-not $items.ContainsKey($name)) {
        $items[$name] = [PSCustomObject]@{
            Channel = $name
            Group = $group
            Count = 0
        }
    }
    $items[$name].Count += 1
}

$items.Values |
    Sort-Object Count, Channel |
    Select-Object Channel, Group, Count |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Tip: channels with Count 0-1 need better local sources or aliases."
