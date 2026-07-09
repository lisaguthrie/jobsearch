<#
.SYNOPSIS
    Concatenates the 01-09 resume section Markdown files into a single Markdown file.

.DESCRIPTION
    Combines the numbered resume section files (01-09) into one file, separated by
    blank lines. Uses "01 Header - TPM.md" and outputs to FullResume.md by default.
    With -Education, uses "01 Header - education.md", inserts "05 Board experience.md"
    before "03 Professional Experience.md", and outputs to FullResumeEducation.md.

    "02 Skills.md" is never used directly - it is passed through
    Convert-SkillsFormat.ps1 first, and the resulting FormattedSkills.md is used
    in its place.

.EXAMPLE
    .\Build-FullResume.ps1

.EXAMPLE
    .\Build-FullResume.ps1 -Education
#>
param(
    [switch]$Education
)

$sectionsDir = $PSScriptRoot

function Get-TrimmedContent {
    param([string]$Path)
    (Get-Content -Path $Path -Raw) -replace '\s+$', '' -replace '^\s+', ''
}

# Regenerate FormattedSkills.md from 02 Skills.md
# (Convert-SkillsFormat.ps1 writes to FormattedSkills.md in the current directory, so run from $sectionsDir)
Push-Location $sectionsDir
try {
    & (Join-Path $sectionsDir 'Convert-SkillsFormat.ps1') -InputPath (Join-Path $sectionsDir '02 Skills.md')
} finally {
    Pop-Location
}

$headerFile = if ($Education) { '01 Header - education.md' } else { '01 Header - TPM.md' }

$orderedFiles = [System.Collections.Generic.List[string]]::new()
$orderedFiles.Add($headerFile)
$orderedFiles.Add('FormattedSkills.md')

if ($Education) {
    $orderedFiles.Add('05 Board experience.md')
    $orderedFiles.Add('03 Professional Experience.md')
    $orderedFiles.Add('04 Additional Relevant Experience.md')
    $orderedFiles.Add('06 Education.md')
} else {
    $orderedFiles.Add('03 Professional Experience.md')
    $orderedFiles.Add('04 Additional Relevant Experience.md')
    $orderedFiles.Add('05 Board experience.md')
    $orderedFiles.Add('06 Education.md')
}

$orderedFiles.Add('08 Volunteer Experience.md')
$orderedFiles.Add('09 Independent Projects.md')

$sections = New-Object System.Collections.Generic.List[string]
foreach ($file in $orderedFiles) {
    $path = Join-Path $sectionsDir $file
    if (-not (Test-Path $path)) {
        throw "Expected section file not found: $path"
    }
    $sections.Add((Get-TrimmedContent -Path $path))
}

$outputName = if ($Education) { 'FullResumeEducation.md' } else { 'FullResume.md' }
$outputPath = Join-Path $sectionsDir $outputName

Set-Content -Path $outputPath -Value ($sections -join "`n`n")

Write-Host "Full resume written to $outputPath"
