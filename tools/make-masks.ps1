<#
.SYNOPSIS
    Generates the icon shape masks in Media\.

.DESCRIPTION
    Writes 128x128 uncompressed 32-bit TGA files: white pixels whose alpha
    channel holds the shape, which is what the game reads from a mask texture.
    Edges are antialiased over one pixel.

      Rounded.tga     square with rounded corners
      Circle.tga      circle with a sharp edge
      SoftCircle.tga  circle that fades out towards its edge

    The generated files are committed; run this only to change the shapes.

.EXAMPLE
    ./tools/make-masks.ps1
#>

$ErrorActionPreference = "Stop"

$size = 128
$media = Join-Path (Split-Path -Parent $PSScriptRoot) "Media"
New-Item -ItemType Directory -Force $media | Out-Null

function Clamp01([double]$value) {
    if ($value -lt 0) { return 0.0 }
    if ($value -gt 1) { return 1.0 }
    return $value
}

# Writes a mask from a function that returns the alpha (0..1) of a point,
# given in pixels from the center of the image.
function Write-Mask([string]$name, [scriptblock]$alphaAt) {
    $pixels = New-Object byte[] ($size * $size * 4)
    $center = $size / 2
    $i = 0
    for ($y = 0; $y -lt $size; $y++) {
        for ($x = 0; $x -lt $size; $x++) {
            $alpha = & $alphaAt ($x + 0.5 - $center) ($y + 0.5 - $center)
            $pixels[$i] = 255
            $pixels[$i + 1] = 255
            $pixels[$i + 2] = 255
            $pixels[$i + 3] = [byte][math]::Round((Clamp01 $alpha) * 255)
            $i += 4
        }
    }

    # TGA header: uncompressed true color, 32 bits, 8 alpha bits, bottom-left origin.
    $header = New-Object byte[] 18
    $header[2] = 2
    $header[12] = $size -band 0xFF
    $header[13] = $size -shr 8
    $header[14] = $size -band 0xFF
    $header[15] = $size -shr 8
    $header[16] = 32
    $header[17] = 8

    $path = Join-Path $media "$name.tga"
    $stream = [IO.File]::Create($path)
    try {
        $stream.Write($header, 0, $header.Length)
        $stream.Write($pixels, 0, $pixels.Length)
    }
    finally {
        $stream.Dispose()
    }
    Write-Host "Wrote $path"
}

$radius = $size / 2 - 1

Write-Mask "Circle" {
    param($x, $y)
    $distance = [math]::Sqrt($x * $x + $y * $y)
    return $radius - $distance + 0.5
}

Write-Mask "SoftCircle" {
    param($x, $y)
    $distance = [math]::Sqrt($x * $x + $y * $y)
    $solid = $radius * 0.6
    if ($distance -le $solid) { return 1.0 }
    $t = Clamp01 (($distance - $solid) / ($radius - $solid))
    return 1 - $t * $t * (3 - 2 * $t)
}

Write-Mask "Rounded" {
    param($x, $y)
    $corner = $size * 0.22
    $half = $radius - $corner
    $qx = [math]::Abs($x) - $half
    $qy = [math]::Abs($y) - $half
    $outside = [math]::Sqrt([math]::Pow([math]::Max($qx, 0), 2) + [math]::Pow([math]::Max($qy, 0), 2))
    $inside = [math]::Min([math]::Max($qx, $qy), 0)
    $distance = $outside + $inside - $corner
    return 0.5 - $distance
}
