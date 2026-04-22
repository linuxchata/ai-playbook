# Determine the repository root relative to this script
$scriptDir = $PSScriptRoot
$repoRoot = if ($scriptDir.EndsWith("scripts")) { Split-Path $scriptDir -Parent } else { $scriptDir }

$gitDir = Join-Path $repoRoot ".git"
$hookSource = Join-Path $repoRoot "scripts/hooks/pre-commit"
$hookDest = Join-Path $gitDir "hooks/pre-commit"

# Ensure the .git directory exists
if (-not (Test-Path $gitDir)) {
    Write-Error "Not a git repository (or .git folder not found at $repoRoot)."
    exit 1
}

if (Test-Path $hookSource) {
    # Ensure hooks directory exists
    $hooksDir = Join-Path $gitDir "hooks"
    if (-not (Test-Path $hooksDir)) {
        New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    }

    Copy-Item -Path $hookSource -Destination $hookDest -Force
    Write-Host "Git pre-commit hook installed successfully to $hookDest"
} else {
    Write-Error "Hook source file not found at $hookSource"
}
