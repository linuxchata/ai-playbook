# Paths
$contentDir = "content"
$templatesDir = "templates"
$claudeSkillsDir = ".claude/skills"
$cursorRulesDir = ".cursor/rules"
$geminiDir = ".gemini/skills"

# Ensure directories exist
if (-not (Test-Path $claudeSkillsDir)) { New-Item -ItemType Directory -Path $claudeSkillsDir -Force | Out-Null }
if (-not (Test-Path $cursorRulesDir)) { New-Item -ItemType Directory -Path $cursorRulesDir -Force | Out-Null }
if (-not (Test-Path $geminiDir)) { New-Item -ItemType Directory -Path $geminiDir -Force | Out-Null }

# Helper to compare content (ignoring line endings and trailing whitespace)
function Test-ContentDifferent($old, $new) {
    if ($null -eq $old) { return $true }
    $oldNorm = $old.Replace("`r`n", "`n").Trim()
    $newNorm = $new.Replace("`r`n", "`n").Trim()
    return $oldNorm -ne $newNorm
}

$files = Get-ChildItem -Path $contentDir -Filter *.md

foreach ($file in $files) {
    $name = $file.BaseName
    $rawContent = [System.IO.File]::ReadAllText($file.FullName)
    
    # Extract description
    # Pattern: Look for ## Description, then skip whitespace/newlines, capture until next header or horizontal rule or end of file
    if ($rawContent -match "## Description\s*\r?\n\r?\n(.*?)\r?\n\r?\n---") {
        $description = $matches[1].Trim()
    } elseif ($rawContent -match "## Description\s*\r?\n\r?\n(.*?)\r?\n") {
        $description = $matches[1].Trim()
    } else {
        $description = ""
    }

    # Claude Skill logic
    $targetClaudeFile = "$claudeSkillsDir/$name/SKILL.md"
    $existingContent = if (Test-Path $targetClaudeFile) { [System.IO.File]::ReadAllText($targetClaudeFile) } else { $null }
    
    $claudeTemplatePath = "$templatesDir/.claude/SKILL.md"
    if (Test-Path $claudeTemplatePath) {
        $claudeTemplate = [System.IO.File]::ReadAllText($claudeTemplatePath)
        
        # Determine current version from file
        $currentVersion = "1.0.0"
        if ($existingContent -and ($existingContent -match "version: (\d+)\.(\d+)\.(\d+)")) {
            $currentVersion = "$($matches[1]).$($matches[2]).$($matches[3])"
        }

        # Generate output with current version to see if it changed
        $claudeOutput = $claudeTemplate.Replace("[[name]]", $name).Replace("[[description]]", $description).Replace("[[metadata_version]]", $currentVersion).Replace("[[content]]", $rawContent)

        if (Test-ContentDifferent $existingContent $claudeOutput) {
            # Content changed, increment version if it's not the first time
            if ($existingContent -and ($existingContent -match "version: (\d+)\.(\d+)\.(\d+)")) {
                $major = [int]$matches[1]; $minor = [int]$matches[2]; $patch = [int]$matches[3]
                $currentVersion = "$major.$($minor + 1).$patch"
                
                # Regenerate with new version
                $claudeOutput = $claudeTemplate.Replace("[[name]]", $name).Replace("[[description]]", $description).Replace("[[metadata_version]]", $currentVersion).Replace("[[content]]", $rawContent)
            }
            
            Write-Host "Updating Claude Skill: $name (Version: $currentVersion)..."
            $targetDir = "$claudeSkillsDir/$name"
            if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
            [System.IO.File]::WriteAllText($targetClaudeFile, $claudeOutput)
        } else {
            Write-Host "Skipping Claude Skill: $name (Up to date at $currentVersion)"
        }
    }

    # Generate Cursor Rule
    $cursorTemplatePath = "$templatesDir/.cursor/rule.mdc"
    if (Test-Path $cursorTemplatePath) {
        $cursorTemplate = [System.IO.File]::ReadAllText($cursorTemplatePath)
        $cursorOutput = $cursorTemplate.Replace("[[description]]", $description).Replace("[[content]]", $rawContent)
        
        $targetCursorFile = "$cursorRulesDir/$name.mdc"
        $existingCursor = if (Test-Path $targetCursorFile) { [System.IO.File]::ReadAllText($targetCursorFile) } else { $null }
        
        if (Test-ContentDifferent $existingCursor $cursorOutput) {
            Write-Host "Updating Cursor Rule: $name"
            [System.IO.File]::WriteAllText($targetCursorFile, $cursorOutput)
        }
    }

    # Generate Gemini Skill
    $geminiTemplatePath = "$templatesDir/.gemini/SKILL.md"
    if (Test-Path $geminiTemplatePath) {
        $geminiTemplate = [System.IO.File]::ReadAllText($geminiTemplatePath)
        $geminiOutput = $geminiTemplate.Replace("{name}", $name).Replace("{description}", $description).Replace("{content}", $rawContent)
        
        $targetGeminiFile = "$geminiDir/$name/SKILL.md"
        $existingGemini = if (Test-Path $targetGeminiFile) { [System.IO.File]::ReadAllText($targetGeminiFile) } else { $null }
        
        if (Test-ContentDifferent $existingGemini $geminiOutput) {
            Write-Host "Updating Gemini Skill: $name"
            $targetGeminiDir = "$geminiDir/$name"
            if (-not (Test-Path $targetGeminiDir)) { New-Item -ItemType Directory -Path $targetGeminiDir -Force | Out-Null }
            [System.IO.File]::WriteAllText($targetGeminiFile, $geminiOutput)
        }
    }
}

Write-Host "Done!"
