<#
.SYNOPSIS
    Converts a header + bullet-point Markdown file into a header + pipe-separated Markdown file.

.EXAMPLE
    .\Convert-SkillsFormat.ps1 -InputPath "Resume\02 Skills.md"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath
)

if (-not (Test-Path $InputPath)) {
    throw "Input file not found: $InputPath"
}

$outputPath = Join-Path -Path (Get-Location) -ChildPath "FormattedSkills.md"

$lines = Get-Content -Path $InputPath
$outputLines = New-Object System.Collections.Generic.List[string]
$currentBullets = New-Object System.Collections.Generic.List[string]

function Flush-Bullets {
    if ($currentBullets.Count -gt 0) {
        $outputLines.Add(($currentBullets -join " | "))
        $currentBullets.Clear()
    }
}

foreach ($line in $lines) {
    $trimmed = $line.Trim()

    if ($trimmed -match '^#{1,6}\s') {
        Flush-Bullets
        $outputLines.Add($trimmed)
    }
    elseif ($trimmed -match '^\*\s+(.*)$') {
        $currentBullets.Add($Matches[1].Trim())
    }
    elseif ($trimmed -eq '') {
        Flush-Bullets
        $outputLines.Add('')
    }
    else {
        Flush-Bullets
        $outputLines.Add($trimmed)
    }
}
Flush-Bullets

Set-Content -Path $outputPath -Value $outputLines

Write-Host "Formatted skills written to $outputPath"
