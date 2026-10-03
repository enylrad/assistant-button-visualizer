<#
.SYNOPSIS
    Builds a shareable zip of the addon.

.DESCRIPTION
    Creates AssistantButtonVisualizer-<version>.zip in the repository root with a single AssistantButtonVisualizer
    folder inside, ready to be extracted into Interface\AddOns. The version is
    read from the TOC. Development files (the same ones .pkgmeta ignores) are
    left out.

    Entries are written with forward slashes: Compress-Archive on Windows
    PowerShell uses backslashes, which some addon managers cannot extract.

.PARAMETER OutDir
    Folder where the zip is written. Defaults to the repository root.

.EXAMPLE
    ./tools/package.ps1
#>
param(
    [string]$OutDir
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$addonName = "AssistantButtonVisualizer"
$root = Split-Path -Parent $PSScriptRoot
if (-not $OutDir) {
    $OutDir = $root
}

$toc = Get-Content (Join-Path $root "$addonName.toc")
$versionLine = $toc | Where-Object { $_ -match '^## Version:\s*(.+)$' } | Select-Object -First 1
if (-not $versionLine) {
    throw "No '## Version' line found in $addonName.toc"
}
$version = ($versionLine -replace '^## Version:\s*', '').Trim()

# Top-level entries that never ship.
$excluded = @(".git", ".release", "tools", "README.md", ".gitattributes", ".gitignore", ".pkgmeta", ".vscode", ".idea")

$zipPath = Join-Path $OutDir "$addonName-$version.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath
}

$files = Get-ChildItem $root -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($root.Length + 1)
    $top = $relative.Split([IO.Path]::DirectorySeparatorChar)[0]
    ($excluded -notcontains $top) -and ($_.Extension -ne ".zip")
}

$zip = [IO.Compression.ZipFile]::Open($zipPath, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($root.Length + 1).Replace('\', '/')
        $entryName = "$addonName/$relative"
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $file.FullName, $entryName, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
}
finally {
    $zip.Dispose()
}

Write-Host "Packaged $($files.Count) files into $zipPath"
