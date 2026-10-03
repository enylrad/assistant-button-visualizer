<#
.SYNOPSIS
    Links this repository into the AddOns folder of every installed WoW flavor.

.DESCRIPTION
    Creates a directory junction named AssistantButtonVisualizer inside <WowRoot>\<flavor>\Interface\AddOns
    for each flavor folder found (_retail_, _classic_, _classic_era_, _anniversary_,
    _classic_beta_, _ptr_, ...). Junctions do not require administrator rights and let
    the game load the working copy directly, so a /reload picks up code changes.

.PARAMETER WowRoot
    World of Warcraft installation folder.

.PARAMETER Flavors
    Optional list of flavor folders to link. Defaults to every "_name_" folder found.

.PARAMETER Remove
    Removes the junctions instead of creating them.

.EXAMPLE
    ./tools/link-wow.ps1
    ./tools/link-wow.ps1 -WowRoot "D:\Games\World of Warcraft" -Flavors _retail_
#>
param(
    [string]$WowRoot = "C:\Program Files (x86)\World of Warcraft",
    [string[]]$Flavors,
    [switch]$Remove
)

$ErrorActionPreference = "Stop"
$addonName = "AssistantButtonVisualizer"
$source = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path $WowRoot)) {
    throw "WoW folder not found: $WowRoot"
}

if (-not $Flavors) {
    $Flavors = Get-ChildItem $WowRoot -Directory |
        Where-Object { $_.Name -match '^_.+_$' } |
        ForEach-Object { $_.Name }
}

foreach ($flavor in $Flavors) {
    $addons = Join-Path $WowRoot "$flavor\Interface\AddOns"
    $target = Join-Path $addons $addonName

    if ($Remove) {
        if (Test-Path $target) {
            # Removing a junction only deletes the link, never the repository.
            (Get-Item $target).Delete()
            Write-Host "Removed $target"
        }
        continue
    }

    New-Item -ItemType Directory -Force $addons | Out-Null
    if (Test-Path $target) {
        $item = Get-Item $target
        if ($item.LinkType -eq "Junction") {
            Write-Host "Already linked: $target"
            continue
        }
        Write-Warning "Skipping $target`: a real folder already exists there."
        continue
    }

    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
    Write-Host "Linked $target -> $source"
}
