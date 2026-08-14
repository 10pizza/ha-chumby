param(
    [Parameter(Mandatory = $true)]
    [string]$UsbRoot,

    [Parameter(Mandatory = $true)]
    [string]$ZurkZip,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$legacyRadio1Url = "http://66.162.107.142/cpr1_lo"
$modernRadio1Url = "https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3"
$modernRadio1PlaylistUrl = "http://localhost/omrop-fryslan.m3u"
$overlayRoot = Join-Path $PSScriptRoot "overlay"
$resolvedUsb = (Resolve-Path -LiteralPath $UsbRoot).Path
$resolvedZip = (Resolve-Path -LiteralPath $ZurkZip).Path

if (-not (Test-Path -LiteralPath $overlayRoot)) {
    throw "Installer overlay not found: $overlayRoot"
}

$zipName = Split-Path -Leaf $resolvedZip
if ($zipName -ne "zurk_chumby_classic.zip") {
    throw "Expected Zurk Classic package named zurk_chumby_classic.zip. Found: $zipName"
}

$drive = Split-Path -Qualifier $resolvedUsb
if ($drive) {
    $driveLetter = $drive.TrimEnd(':')
    $volume = Get-Volume -DriveLetter $driveLetter -ErrorAction SilentlyContinue
    if ($volume -and $volume.FileSystem -ne "FAT32") {
        throw "USB volume must be FAT32. Found: $($volume.FileSystem)"
    }
}

$existing = Get-ChildItem -LiteralPath $resolvedUsb -Force | Where-Object { $_.Name -notin @('.', '..') }
if ($existing -and -not $Force) {
    throw "USB root is not empty. Re-run with -Force after confirming this is the intended USB stick."
}

Expand-Archive -LiteralPath $resolvedZip -DestinationPath $resolvedUsb -Force

$originalDebug = Join-Path $resolvedUsb "debugchumby"
if (Test-Path -LiteralPath $originalDebug) {
    Copy-Item -LiteralPath $originalDebug -Destination (Join-Path $resolvedUsb "debugchumby.zurk-original") -Force
}

Get-ChildItem -LiteralPath $overlayRoot -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $resolvedUsb -Recurse -Force
}

$pspRoot = Join-Path $resolvedUsb "psp"
$firstTime = Join-Path $pspRoot "firsttime"
if (Test-Path -LiteralPath $firstTime) {
    Copy-Item -LiteralPath $firstTime -Destination (Join-Path $pspRoot "firsttime.zurk-original") -Force
    [System.IO.File]::WriteAllText($firstTime, "0`n", [System.Text.Encoding]::ASCII)
}

$controlCgi = Join-Path $resolvedUsb "lighty\cgi-bin\chumote\control.cgi"
if (Test-Path -LiteralPath $controlCgi) {
    $controlText = [System.IO.File]::ReadAllText($controlCgi)
    if ($controlText.Contains($legacyRadio1Url)) {
        Copy-Item -LiteralPath $controlCgi -Destination (Join-Path (Split-Path -Parent $controlCgi) "control.cgi.zurk-original") -Force
        $patchedControlText = $controlText.Replace($legacyRadio1Url, $modernRadio1Url)
        [System.IO.File]::WriteAllText($controlCgi, $patchedControlText, [System.Text.Encoding]::ASCII)
    }
}


$playlistPath = Join-Path $resolvedUsb "lighty\html\omrop-fryslan.m3u"
$playlistDir = Split-Path -Parent $playlistPath
if (Test-Path -LiteralPath $playlistDir) {
    [System.IO.File]::WriteAllText($playlistPath, "$modernRadio1Url`n", [System.Text.Encoding]::ASCII)
}

$urlStreams = Join-Path $pspRoot "url_streams"
if (Test-Path -LiteralPath $urlStreams) {
    Copy-Item -LiteralPath $urlStreams -Destination (Join-Path $pspRoot "url_streams.ha-chumby-original") -Force
    $streamXml = ('<streams><stream url="{0}" id="" mimetype="audio/x-mpegurl" name="Omrop Fryslan" /></streams>' -f $modernRadio1PlaylistUrl) + "`n"
    [System.IO.File]::WriteAllText($urlStreams, $streamXml, [System.Text.Encoding]::ASCII)
}

$manifest = @(
    "HA-Chumby USB MVP manifest",
    "Prepared: $(Get-Date -Format o)",
    "Zurk package expected: zurk_chumby_classic.zip",
    "Startup entrypoint: /debugchumby",
    "Application: /ha-chumby/start.sh",
    "Boot screen: /ha-chumby/boot-screen.rgb565",
    "Original Zurk debugchumby backup: /debugchumby.zurk-original if present",
    "USB PSP configured-state marker: /psp/firsttime=0 when present",
    "Original Zurk firsttime backup: /psp/firsttime.zurk-original if present",
    "Radio1 preset: legacy CPR URL replaced with Omrop Fryslan when /lighty/cgi-bin/chumote/control.cgi is present",
    "Original control.cgi backup: /lighty/cgi-bin/chumote/control.cgi.zurk-original if patched",
    "Omrop Fryslan playlist wrapper: /omrop-fryslan.m3u when /lighty/html exists",
    "Stream list configured through /psp/url_streams with backup /psp/url_streams.ha-chumby-original when present"
)
Set-Content -LiteralPath (Join-Path $resolvedUsb "HA-CHUMBY-MANIFEST.txt") -Value $manifest -Encoding ASCII

$requiredFiles = @(
    "debugchumby",
    "HA-CHUMBY-MANIFEST.txt",
    "ha-chumby\start.sh",
    "ha-chumby\boot-screen.rgb565",
    "psp\firsttime"
)

$missing = @()
foreach ($relativePath in $requiredFiles) {
    $target = Join-Path $resolvedUsb $relativePath
    if (-not (Test-Path -LiteralPath $target)) {
        $missing += $relativePath
    }
}

if ($missing.Count -gt 0) {
    throw "USB preparation incomplete. Missing: $($missing -join ', ')"
}

Write-Host "HA-Chumby USB stick prepared at $resolvedUsb"
Write-Host "Verified debugchumby, HA-CHUMBY-MANIFEST.txt, ha-chumby/start.sh, ha-chumby/boot-screen.rgb565, and psp/firsttime."