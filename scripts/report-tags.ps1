[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$siteRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$registryPath = Join-Path $siteRoot 'data\tags.yaml'
$postRoot = Join-Path $siteRoot 'content\posts'

$registry = [ordered]@{}
$currentTag = $null
foreach ($line in Get-Content $registryPath) {
    if ($line -match '^([a-z0-9]+(?:-[a-z0-9]+)*):\s*$') {
        $currentTag = $Matches[1]
        $registry[$currentTag] = [PSCustomObject]@{
            Label = ''
            Posts = [Collections.Generic.List[string]]::new()
        }
        continue
    }

    if ($currentTag -and $line -match '^\s{2}label:\s*(.+?)\s*$') {
        $registry[$currentTag].Label = $Matches[1].Trim('"', "'")
    }
}

$errors = [Collections.Generic.List[string]]::new()
foreach ($file in Get-ChildItem $postRoot -Recurse -Filter 'index.md') {
    $lines = Get-Content $file.FullName
    if ($lines.Count -eq 0 -or $lines[0] -ne '---') {
        $errors.Add("Missing YAML front matter: $($file.FullName)")
        continue
    }

    $frontMatterEnd = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '---') {
            $frontMatterEnd = $i
            break
        }
    }
    if ($frontMatterEnd -lt 0) {
        $errors.Add("Unclosed YAML front matter: $($file.FullName)")
        continue
    }

    $tags = [Collections.Generic.List[string]]::new()
    for ($i = 1; $i -lt $frontMatterEnd; $i++) {
        if ($lines[$i] -ne 'tags:') {
            continue
        }
        for ($j = $i + 1; $j -lt $frontMatterEnd; $j++) {
            if ($lines[$j] -match '^\s+-\s+(.+?)\s*$') {
                $tags.Add($Matches[1].Trim('"', "'"))
                continue
            }
            break
        }
        break
    }

    if ($tags.Count -eq 0) {
        $errors.Add("No tags: $($file.FullName)")
        continue
    }
    if ($tags.Count -gt 4) {
        $errors.Add("More than four tags: $($file.FullName)")
    }

    $relativePath = [IO.Path]::GetRelativePath($siteRoot, $file.FullName)
    foreach ($tag in $tags) {
        if (-not $registry.Contains($tag)) {
            $errors.Add("Unknown tag '$tag': $relativePath")
            continue
        }
        if ($registry[$tag].Posts.Contains($relativePath)) {
            $errors.Add("Duplicate tag '$tag': $relativePath")
            continue
        }
        $registry[$tag].Posts.Add($relativePath)
    }
}

$rows = foreach ($tag in ($registry.Keys | Sort-Object)) {
    [PSCustomObject]@{
        Tag = $tag
        Label = $registry[$tag].Label
        Posts = $registry[$tag].Posts.Count
    }
}
$rows | Format-Table -AutoSize

$unused = $rows | Where-Object Posts -eq 0 | Select-Object -ExpandProperty Tag
if ($unused) {
    Write-Host "Unused registered tags: $($unused -join ', ')"
}

if ($errors.Count -gt 0) {
    throw ($errors -join [Environment]::NewLine)
}
