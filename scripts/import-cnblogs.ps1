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
        Title = '每天一个爆零小技巧'
        Description = '从比赛策略、调试习惯到常用程序片段：一份带有个人风格的竞赛避坑清单。'
        Tags = @('competitive-programming', 'misc', 'tips')
        Featured = $true
    },
    [PSCustomObject]@{
        Id = 11565041
        Slug = 'dujiao-sieve-dirichlet-convolution'
        Title = '杜教筛、狄利克雷卷积及一些怪东西'
        Description = '杜教筛、狄利克雷卷积与常见积性函数的一份旧学习笔记。'
        Tags = @('algorithms', 'number-theory', 'notes')
        Featured = $true
        Replacements = [ordered]@{
            'https://www.luogu.org/problemnew/show/P4213' = 'https://www.luogu.com.cn/problem/P4213'
        }
    },
    [PSCustomObject]@{
        Id = 14035337
        Slug = 'snoi2020-range-sum'
        Title = 'SNOI 2020「区间和」题解'
        Description = '从线段树与势能分析出发，整理 SNOI2020 区间和问题的关键维护方式。'
        Tags = @('algorithms', 'data-structures', 'problem-solution')
        Featured = $true
    },
    [PSCustomObject]@{
        Id = 11669045
        Slug = 'game-theory-notes'
        Title = '博弈论学习笔记：Nim、SG 函数与常见变体'
        Description = '从 Nim 与 SG 函数出发，整理平等组合游戏、常见变体以及错误推广的反例。'
        Tags = @('algorithms', 'game-theory', 'notes')
        Featured = $false
        Replacements = [ordered]@{
            '![](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9zMi5heDF4LmNvbS8yMDE5LzEwLzE0L0twY003VC5wbmc?x-oss-process=image/format,png)' = '![有向图反例](nim-counterexample.png)'
        }
    },
    [PSCustomObject]@{
        Id = 11701276
        Slug = 'pollards-rho-notes'
        Title = "Pollard's rho 学习笔记"
        Description = "从生日悖论和 Floyd 判环理解 Pollard's rho，并记录实现演进与常见优化。"
        Tags = @('algorithms', 'number-theory', 'notes')
        Featured = $false
    },
    [PSCustomObject]@{
        Id = 13055003
        Slug = 'round-square-tree-notes'
        Title = '圆方树学习笔记'
        Description = '从仙人掌判定到圆方树建模，整理常见构造方式和若干题目实现。'
        Tags = @('algorithms', 'data-structures', 'graph-theory', 'notes')
        Featured = $false
    },
    [PSCustomObject]@{
        Id = 14515009
        Slug = 'constant-range-update-block-structure'
        Title = '一种支持常数区间修改的分块结构'
        Description = '一种以多层分块换取常数区间修改、平方根级单点查询的实验性数据结构。'
        Tags = @('algorithms', 'data-structures', 'notes')
        Featured = $false
    },
    [PSCustomObject]@{
        Id = 11356317
        Slug = 'noi2018-your-name'
        Title = 'NOI 2018「你的名字」题解'
        Description = '利用后缀自动机与可持久化线段树维护 endpos 集合，处理区间限制下的不同子串计数。'
        Tags = @('algorithms', 'problem-solution', 'string-algorithms')
        Featured = $false
        Replacements = [ordered]@{
            'https://www.luogu.org/problem/P4770' = 'https://www.luogu.com.cn/problem/P4770'
        }
    },
    [PSCustomObject]@{
        Id = 13862052
        Slug = 'sdoi2017-tree-coloring'
        Title = 'SDOI 2017「树点涂色」题解'
        Description = '把颜色段转化为父子差分，用 LCT 与线段树维护根路径染色及查询。'
        Tags = @('algorithms', 'data-structures', 'problem-solution')
        Featured = $false
    },
    [PSCustomObject]@{
        Id = 13999541
        Slug = 'icpc-wf-2015-tile-cutting'
        Title = 'ICPC World Finals 2015「Tile Cutting」题解'
        Description = '将平行四边形面积计数转化为约数函数卷积，并使用 NTT 求解。'
        Tags = @('algorithms', 'combinatorics', 'polynomials', 'problem-solution')
        Featured = $false
        Replacements = [ordered]@{
            'http://codeforces.com/gym/101239' = 'https://codeforces.com/gym/101239'
        }
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
    $frontMatter.Add("title: $(ConvertTo-YamlString $item.Title)")
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
    if ($item.PSObject.Properties.Name -contains 'Replacements') {
        foreach ($replacement in $item.Replacements.GetEnumerator()) {
            $body = $body.Replace($replacement.Key, $replacement.Value)
        }
    }
    # The Blog Garden export sometimes breaks a Markdown link before its closing
    # parenthesis. Join only that unambiguous pattern and leave prose line breaks alone.
    $body = $body -replace '(https?://[^\s)]+)\n\)', '$1)'
    $body = (($body -split "`n") | ForEach-Object { $_.TrimEnd() }) -join "`n"
    $content = (($frontMatter -join "`n") + "`n" + $body + "`n")
    $target = Join-Path $targetDir 'index.md'
    [IO.File]::WriteAllText($target, $content, $utf8)
    Write-Host "Imported $($post.Id) -> $target"
}
