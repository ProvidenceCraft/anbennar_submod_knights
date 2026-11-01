# Generate override files from the local Anbennar install.
# Usage: pwsh -File tools/build_overrides.ps1
# ASCII-only on purpose: PowerShell reads BOM-less .ps1 as ANSI on Windows.

param(
    [string]$Anbennar = 'E:\SteamLibrary\steamapps\workshop\content\236850\2939497607',
    [string]$Repo     = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$mod = Join-Path $Repo 'anbennar_knights'

function Write-Utf8Bom([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($true)))
}

# --- 1) government reforms: add escann_knights_reform to tier 1 ---
$srcGov = Join-Path $Anbennar 'common\governments\00_governments.txt'
if (-not (Test-Path $srcGov)) { throw "missing $srcGov" }

$text = [System.IO.File]::ReadAllText($srcGov)
$anchor = 'feudalism_vs_autocracy'
$i = $text.IndexOf($anchor)
if ($i -lt 0) { throw 'anchor feudalism_vs_autocracy not found' }

$r = $text.IndexOf('reforms', $i)
if ($r -lt 0) { throw 'reforms keyword not found' }

$b = $text.IndexOf([char]'{', $r)
if ($b -lt 0) { throw 'reforms brace not found' }

if ($text.IndexOf('escann_knights_reform') -ge 0) {
    Write-Host 'reform already present, skip'
} else {
    $insert = "`r`n`t`t`t`tescann_knights_reform"
    $text = $text.Insert($b + 1, $insert)
    Write-Host 'inserted escann_knights_reform at tier 1'
}

Write-Utf8Bom (Join-Path $mod 'common\governments\00_governments.txt') $text

# --- 2) static modifiers: banner_regiment bonuses + per-dev cap ---
$srcSt = Join-Path $Anbennar 'common\static_modifiers\00_static_modifiers.txt'
if (-not (Test-Path $srcSt)) { throw "missing $srcSt" }

$st = [System.IO.File]::ReadAllText($srcSt)

$knightBlock = @"
banner_regiment = {
	discipline = 0.05
	shock_damage = 0.1
	morale_damage_received = -0.2
	regiment_manpower_usage = -0.75
	land_maintenance_modifier = -0.5
	reinforce_cost_modifier = 0.75
	reinforce_speed = -0.5
}
"@

$st2 = [regex]::Replace($st, '(?s)banner_regiment\s*=\s*\{.*?\r?\n\}', $knightBlock.TrimEnd(), 1)
if ($st2 -eq $st) { Write-Warning 'banner_regiment block not replaced' } else { Write-Host 'banner_regiment rewritten with knight bonuses' }
$st = $st2
$m = [regex]::Match($st, 'local_amount_of_banners\s*=\s*([0-9.]+)')
if (-not $m.Success) {
    Write-Warning 'local_amount_of_banners not found, skipped'
} else {
    $old = $m.Groups[1].Value
    $start = $m.Groups[1].Index
    $st = $st.Remove($start, $old.Length).Insert($start, '0.05')
    Write-Host "development local_amount_of_banners $old -> 0.05"
    Write-Utf8Bom (Join-Path $mod 'common\static_modifiers\00_static_modifiers.txt') $st
}

# --- 3) localisation files need a UTF-8 BOM ---
Get-ChildItem (Join-Path $mod 'localisation') -Filter '*.yml' -ErrorAction SilentlyContinue | ForEach-Object {
    $t = [System.IO.File]::ReadAllText($_.FullName)
    Write-Utf8Bom $_.FullName $t
    Write-Host "BOM written: $($_.Name)"
}

Write-Host 'done'
