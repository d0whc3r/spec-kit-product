<#
.SYNOPSIS
  Resolve the active feature directory for /speckit-product-spec.

.DESCRIPTION
  Reads `.specify/feature.json#feature_directory`, validates it points to an
  existing directory, and prints the absolute path on stdout. Mirrors
  scripts/bash/resolve-feature-dir.sh.

.PARAMETER FeatureDir
  Override the pointer with an explicit absolute or repo relative path.

.OUTPUTS
  String. Absolute path of the feature directory.

.NOTES
  Exit codes:
    0  success
    2  E_NO_PROJECT  no .specify/ directory found in any ancestor
    3  E_NO_POINTER  .specify/feature.json missing or unreadable
    4  E_BAD_POINTER feature_directory empty or points to non existent dir
#>

[CmdletBinding()]
param(
    [string]$FeatureDir
)

$ErrorActionPreference = 'Stop'

function Find-ProjectRoot {
    param([string]$StartDir)
    $dir = $StartDir
    while ($dir -and $dir -ne [System.IO.Path]::GetPathRoot($dir)) {
        if (Test-Path (Join-Path $dir '.specify') -PathType Container) {
            return $dir
        }
        $dir = Split-Path $dir -Parent
    }
    if ($dir -and (Test-Path (Join-Path $dir '.specify') -PathType Container)) {
        return $dir
    }
    return $null
}

$projectRoot = Find-ProjectRoot -StartDir (Get-Location).Path
if (-not $projectRoot) {
    Write-Error "[product] E_NO_PROJECT: no .specify/ directory found in any ancestor of $((Get-Location).Path)"
    exit 2
}

if ($FeatureDir) {
    if ([System.IO.Path]::IsPathRooted($FeatureDir)) {
        $resolved = $FeatureDir
    } else {
        $resolved = Join-Path $projectRoot $FeatureDir
    }
} else {
    $pointer = Join-Path $projectRoot '.specify/feature.json'
    if (-not (Test-Path $pointer -PathType Leaf)) {
        Write-Error "[product] E_NO_POINTER: $pointer not found. Run /speckit-specify first or pass -FeatureDir."
        exit 3
    }

    try {
        $json = Get-Content $pointer -Raw | ConvertFrom-Json
    } catch {
        Write-Error "[product] E_NO_POINTER: $pointer is not valid JSON: $_"
        exit 3
    }

    $featureDirField = $json.feature_directory
    if (-not $featureDirField) {
        Write-Error "[product] E_NO_POINTER: feature_directory missing from $pointer. Pass -FeatureDir to override."
        exit 3
    }

    if ([System.IO.Path]::IsPathRooted($featureDirField)) {
        $resolved = $featureDirField
    } else {
        $resolved = Join-Path $projectRoot $featureDirField
    }
}

if (-not (Test-Path $resolved -PathType Container)) {
    Write-Error "[product] E_BAD_POINTER: feature directory does not exist: $resolved"
    exit 4
}

(Resolve-Path $resolved).Path
