[CmdletBinding()]
param(
    [string]$ArchivePath = (Join-Path $PSScriptRoot '..\cnblogs_blog_czyarl.20260830115135.zip')
)

$ErrorActionPreference = 'Stop'
$siteRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$archive = (Resolve-Path $ArchivePath).Path

$selection = @(
    [PSCustomObject]@{
        Id = 12985304
        Slug = 'competitive-programming-tips'
        Description = '从比赛策略、调试习惯到常用程序片段：一份带有个人风格的竞赛避坑清单。'
        Tags = @('competitive-programming', 'misc', 'tips')
        Featured = $true
    },
    [PSCustomObject]@{
        Id = 11565041
        Slug = 'dujiao-sieve-dirichlet-convolution'
        Description = '杜教筛、狄利克雷卷积与常见积性函数的一份旧学习笔记。'
        Tags = @('algorithms', 'number-theory', 'tutorial')
        Featured = $true
    },
    [PSCustomObject]@{
        Id = 14035337
        Slug = 'snoi2020-range-sum'
        Description = '从线段树与势能分析出发，整理 SNOI2020 区间和问题的关键维护方式。'
        Tags = @('algorithms', 'data-structures', 'problem-solution', 'segment-tree')
        Featured = $true
    }
)

function ConvertTo-YamlString([string]$Value) {
    return ($Value | ConvertTo-Json -Compress)
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    $entry = $zip.GetEntry('posts.json')
    if (-not $entry) {
        throw 'posts.json was not found in the archive.'
    }

    $reader = [IO.StreamReader]::new($entry.Open())
    try {
        $posts = $reader.ReadToEnd() | ConvertFrom-Json
    }
    finally {
        $reader.Dispose()
    }
}
finally {
    $zip.Dispose()
}

$utf8 = [Text.UTF8Encoding]::new($false)
foreach ($item in $selection) {
    $post = $posts | Where-Object { $_.Id -eq $item.Id } | Select-Object -First 1
    if (-not $post) {
        throw "Post $($item.Id) was not found in posts.json."
    }

    $targetDir = Join-Path $siteRoot "content\posts\$($item.Slug)"
    New-Item -ItemType Directory -Force $targetDir | Out-Null

    $frontMatter = [Collections.Generic.List[string]]::new()
    $frontMatter.Add('---')
    $frontMatter.Add("title: $(ConvertTo-YamlString $post.Title)")
    $frontMatter.Add("description: $(ConvertTo-YamlString $item.Description)")
    $frontMatter.Add("date: $(([datetime]$post.DateAdded).ToString('yyyy-MM-ddTHH:mm:sszzz'))")
    $frontMatter.Add("lastmod: $(([datetime]$post.DateUpdated).ToString('yyyy-MM-ddTHH:mm:sszzz'))")
    $frontMatter.Add("slug: $($item.Slug)")
    $frontMatter.Add('tags:')
    foreach ($tag in $item.Tags) {
        $frontMatter.Add("  - $tag")
    }
    $frontMatter.Add("featured: $($item.Featured.ToString().ToLowerInvariant())")
    $frontMatter.Add('legacy: true')
    $frontMatter.Add("math: $((($post.Body -match '\$') -or ($post.Body -match '\\\[')).ToString().ToLowerInvariant())")
    $frontMatter.Add("originalId: $($post.Id)")
    $frontMatter.Add("originalURL: https://www.cnblogs.com/czyarl/p/$($post.Id).html")
    $frontMatter.Add('---')
    $frontMatter.Add('')

    $body = ($post.Body -replace "`r`n", "`n").Trim()
    $content = (($frontMatter -join "`n") + "`n" + $body + "`n")
    $target = Join-Path $targetDir 'index.md'
    [IO.File]::WriteAllText($target, $content, $utf8)
    Write-Host "Imported $($post.Id) -> $target"
}
