# Generate override files from the local Anbennar install.
# Usage: pwsh -File tools/build_overrides.ps1
# ASCII-only on purpose: PowerShell reads BOM-less .ps1 as ANSI on Windows.

param(
    [string]$Anbennar = 'E:\SteamLibrary\steamapps\workshop\content\236850\2939497607',
    [string]$Repo     = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$mod = Join-Path $Repo 'anbennar_knights'

function Write-Utf8NoBom([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

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
    $text = $text.Insert($b + 1, "`n`t`t`t`tescann_knights_reform")
    Write-Host 'inserted escann_knights_reform at tier 1'
}

Write-Utf8NoBom (Join-Path $mod 'common\governments\00_governments.txt') $text

# --- 2) cultures: province banner flag only (country flag belongs to the shifter culture) ---
$srcCu = Join-Path $Anbennar 'common\cultures\anb_cultures.txt'
if (-not (Test-Path $srcCu)) { throw "missing $srcCu" }
$cu = [System.IO.File]::ReadAllText($srcCu, [System.Text.Encoding]::GetEncoding(1252))

foreach ($k in @('castanorian','castellyrian','marcher','adenner','farrani_half_elf')) {
    $re = [regex]("(?m)^[ \t]*" + [regex]::Escape($k) + "[ \t]*=[ \t]*\{")
    $m = $re.Match($cu)
    if ($m.Success) {
        $at = $m.Index + $m.Length
        $cu = $cu.Insert($at, "`n`t`tprovince = { local_has_banners = yes }")
        Write-Host "banner province culture: $k"
    } else {
        Write-Warning "culture not found: $k"
    }
}

Write-Utf8NoBom (Join-Path $mod 'common\cultures\anb_cultures.txt') $cu

# --- 3) countries: give the four realms the Escann knight units ---
foreach ($name in @('Castanor','Blademarches','Adenica','Farranean')) {
    $src = Join-Path $Anbennar "common\countries\$name.txt"
    if (-not (Test-Path $src)) { Write-Warning "missing country: $name"; continue }
    $c = [System.IO.File]::ReadAllText($src, [System.Text.Encoding]::GetEncoding(1252))
    if ($c.IndexOf('escann_knight_banner') -ge 0) {
        Write-Host "$name already has knight units"
    } else {
        $idx = $c.IndexOf('historical_units')
        if ($idx -lt 0) { Write-Warning "$name has no historical_units"; continue }
        $brace = $c.IndexOf([char]'{', $idx)
        if ($brace -lt 0) { Write-Warning "$name historical_units brace missing"; continue }
        $c = $c.Insert($brace + 1, "`n`t`tescann_knight_banner`n`t`tescann_foot_banner")
        Write-Host "$name units added"
    }
    Write-Utf8NoBom (Join-Path $mod "common\countries\$name.txt") $c
}

# --- 4) localisation files need a UTF-8 BOM ---
Get-ChildItem (Join-Path $mod 'localisation') -Filter '*.yml' -ErrorAction SilentlyContinue | ForEach-Object {
    $t = [System.IO.File]::ReadAllText($_.FullName)
    Write-Utf8Bom $_.FullName $t
    Write-Host "BOM written: $($_.Name)"
}

Write-Host 'done'
