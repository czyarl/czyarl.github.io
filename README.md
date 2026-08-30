# czyarl.github.io

czyarl 的个人博客，用来保存学习笔记，以及从旧博客中筛选后迁入的文章。

站点使用 [Hugo](https://gohugo.io/) 生成，采用仓库内的轻量自有布局，不依赖 Node/npm 或第三方主题。数学公式在构建期生成 HTML+MathML，并自托管 KaTeX 0.17.0 的样式和字体，不需要浏览器端 JavaScript。`main` 分支只保存源码；GitHub Actions 构建后以 Pages artifact 发布到 <https://czyarl.github.io/>。

## 本地预览

安装 Hugo `0.165.0`，然后运行：

```bash
hugo server -D
```

生产构建：

```bash
hugo --gc --minify
```

构建结果位于 `public/`，该目录不应提交。

## 新建文章

每篇文章使用 leaf page bundle，让正文和图片放在同一个目录：

```bash
hugo new content posts/my-stable-slug/index.md
```

目录结构：

```text
content/posts/my-stable-slug/
├── index.md
└── diagram.png
```

公开 URL 固定为 `/posts/my-stable-slug/`。不要把日期、标签或文章类型写入 URL。

Front matter 示例：

```yaml
---
title: LLM 推理中的 KV Cache
description: 从内存布局理解 KV Cache 的收益与代价。
date: 2026-08-30T12:00:00+08:00
lastmod: 2026-08-30T12:00:00+08:00
draft: true
featured: false
math: true
tags:
  - ai
  - llm
  - inference
---
```

## 标签规则

文章只使用一个多值 `tags` 字段，不设置互斥 category。

- 标签规范名集中登记在 [`data/tags.yaml`](data/tags.yaml)。
- 标签名统一使用 ASCII 小写 kebab-case。
- 新标签必须先加入词表，再用于文章。
- 别名只供导入器归一化；新文章只写规范名。
- 每篇文章保留 1–4 个真正有检索价值的标签，优先选择“主题 + 内容形式”。
- 具体算法名只有预计会被多篇文章复用时才建立标签，否则留在标题和正文中供搜索。
- Hugo 构建会检查未知标签、大写标签、重复标签、缺失说明和别名冲突。

查看标签库及各标签文章数量：

```powershell
pwsh ./scripts/report-tags.ps1
```

## 旧博客试迁移

博客园原始导出包不会提交到 Git。把导出 zip 放在仓库根目录后运行：

```powershell
pwsh ./scripts/import-cnblogs.ps1
```

脚本当前白名单包含十篇经过完整性和保留价值筛选的文章：

- 《每天一个爆零小技巧》
- 《杜教筛及狄利克雷卷积及一些怪东西》
- 《SNOI2020 区间和》
- 《博弈论学习笔记：Nim、SG 函数与常见变体》
- 《Pollard's rho 学习笔记》
- 《圆方树学习笔记》
- 《一种支持常数区间修改的分块结构》
- 《NOI 2018“你的名字”题解》
- 《SDOI 2017“树点涂色”题解》
- 《ICPC World Finals 2015“Tile Cutting”题解》

后续文章仍应先加入脚本白名单，并人工确认内容完整、有保留价值后再发布，不做整站无差别导入。迁移只表示存档，不表示旧文中的理解、结论或代码已经重新验证。

## GitHub Pages

首次推送后，在仓库中选择：

```text
Settings → Pages → Source → GitHub Actions
```

之后每次推送到 `main` 都会自动构建和部署。工作流固定 Hugo 版本，并使用 GitHub-hosted `ubuntu-latest` runner。
