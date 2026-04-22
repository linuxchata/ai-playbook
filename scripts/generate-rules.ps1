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

    # Versioning logic (from Claude file)
    $targetClaudeFile = "$claudeSkillsDir/$name/SKILL.md"
    $version = "1.0.0"
    if (Test-Path $targetClaudeFile) {
        $existingContent = [System.IO.File]::ReadAllText($targetClaudeFile)
        if ($existingContent -match "version: (\d+)\.(\d+)\.(\d+)") {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            $patch = [int]$matches[3]
            $version = "$major.$($minor + 1).$patch"
        }
    }

    Write-Host "Processing $name (Version: $version)..."

    # Generate Claude Skill
    $claudeTemplatePath = "$templatesDir/.claude/SKILL.md"
    if (Test-Path $claudeTemplatePath) {
        $claudeTemplate = [System.IO.File]::ReadAllText($claudeTemplatePath)
        $claudeOutput = $claudeTemplate.Replace("[[name]]", $name)
        $claudeOutput = $claudeOutput.Replace("[[description]]", $description)
        $claudeOutput = $claudeOutput.Replace("[[metadata_version]]", $version)
        $claudeOutput = $claudeOutput.Replace("[[content]]", $rawContent)
        
        $targetDir = "$claudeSkillsDir/$name"
        if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
        [System.IO.File]::WriteAllText($targetClaudeFile, $claudeOutput)
    }

    # Generate Cursor Rule
    $cursorTemplatePath = "$templatesDir/.cursor/rule.mdc"
    if (Test-Path $cursorTemplatePath) {
        $cursorTemplate = [System.IO.File]::ReadAllText($cursorTemplatePath)
        $cursorOutput = $cursorTemplate.Replace("[[description]]", $description)
        $cursorOutput = $cursorOutput.Replace("[[content]]", $rawContent)
        
        [System.IO.File]::WriteAllText("$cursorRulesDir/$name.mdc", $cursorOutput)
    }

    # Generate Gemini Skill
    $geminiTemplatePath = "$templatesDir/.gemini/SKILL.md"
    if (Test-Path $geminiTemplatePath) {
        $geminiTemplate = [System.IO.File]::ReadAllText($geminiTemplatePath)
        $geminiOutput = $geminiTemplate.Replace("{name}", $name)
        $geminiOutput = $geminiOutput.Replace("{description}", $description)
        $geminiOutput = $geminiOutput.Replace("{content}", $rawContent)
        
        $targetGeminiDir = "$geminiDir/$name"
        if (-not (Test-Path $targetGeminiDir)) { New-Item -ItemType Directory -Path $targetGeminiDir -Force | Out-Null }
        [System.IO.File]::WriteAllText("$targetGeminiDir/SKILL.md", $geminiOutput)
    }
}

Write-Host "Done!"
