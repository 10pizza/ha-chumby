param(
    [Parameter(Mandatory = $true)]
    [string]$UsbRoot,

    [Parameter(Mandatory = $true)]
    [string]$ZurkZip,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

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

$manifest = @(
    "HA-Chumby USB MVP manifest",
    "Prepared: $(Get-Date -Format o)",
    "Zurk package expected: zurk_chumby_classic.zip",
    "Startup entrypoint: /debugchumby",
    "Application: /ha-chumby/start.sh",
    "Boot screen: /ha-chumby/boot-screen.rgb565",
    "Original Zurk debugchumby backup: /debugchumby.zurk-original if present"
)
Set-Content -LiteralPath (Join-Path $resolvedUsb "HA-CHUMBY-MANIFEST.txt") -Value $manifest -Encoding ASCII

$requiredFiles = @(
    "debugchumby",
    "HA-CHUMBY-MANIFEST.txt",
    "ha-chumby\start.sh",
    "ha-chumby\boot-screen.rgb565"
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
Write-Host "Verified debugchumby, HA-CHUMBY-MANIFEST.txt, ha-chumby/start.sh, and ha-chumby/boot-screen.rgb565."
