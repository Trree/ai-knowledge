param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-Text {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Text {
    param(
        [string]$Path,
        [string]$Content
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Get-RelativePath {
    param(
        [string]$Base,
        [string]$Path
    )

    $basePath = [System.IO.Path]::GetFullPath($Base)
    if (-not $basePath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $basePath += [System.IO.Path]::DirectorySeparatorChar
    }

    $baseUri = New-Object System.Uri($basePath)
    $targetUri = New-Object System.Uri([System.IO.Path]::GetFullPath($Path))
    $relative = $baseUri.MakeRelativeUri($targetUri).ToString().Replace("\", "/")
    return [System.Uri]::UnescapeDataString($relative)
}

function Get-TextHash {
    param([string]$Text)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return -join ($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") })
    } finally {
        $sha.Dispose()
    }
}

function ConvertTo-PlainHashtable {
    param($Value)

    if ($null -eq $Value) {
        return @{}
    }

    if ($Value -is [string] -or $Value -is [int] -or $Value -is [long] -or $Value -is [double] -or $Value -is [bool]) {
        return $Value
    }

    if ($Value -is [System.Collections.IDictionary]) {
        $copy = @{}
        foreach ($key in $Value.Keys) {
            $copy[[string]$key] = ConvertTo-PlainHashtable $Value[$key]
        }
        return $copy
    }

    if ($Value -is [pscustomobject]) {
        $copy = @{}
        foreach ($property in $Value.PSObject.Properties) {
            $copy[$property.Name] = ConvertTo-PlainHashtable $property.Value
        }
        return $copy
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        $items = @()
        foreach ($item in $Value) {
            $items += ,(ConvertTo-PlainHashtable $item)
        }
        return $items
    }

    return $Value
}

function Parse-Frontmatter {
    param([string]$Text)

    $match = [regex]::Match($Text, "(?ms)\A---\r?\n(.*?)\r?\n---\r?\n(.*)\z")
    if (-not $match.Success) {
        return @{
            Frontmatter = @{}
            Body = $Text
        }
    }

    $frontmatter = @{}
    foreach ($line in ($match.Groups[1].Value -split "\r?\n")) {
        $lineMatch = [regex]::Match($line, "^\s*([^:]+):\s*(.*)$")
        if ($lineMatch.Success) {
            $frontmatter[$lineMatch.Groups[1].Value.Trim()] = $lineMatch.Groups[2].Value.Trim()
        }
    }

    return @{
        Frontmatter = $frontmatter
        Body = $match.Groups[2].Value
    }
}

function Parse-Sections {
    param([string]$Body)

    $sections = @{}
    $matches = [regex]::Matches($Body, "(?ms)^##\s+([^\r\n]+)\r?\n(.*?)(?=^##\s+|\z)")
    foreach ($match in $matches) {
        $sections[$match.Groups[1].Value.Trim()] = $match.Groups[2].Value.Trim()
    }
    return $sections
}

function Collapse-Whitespace {
    param([string]$Text)

    return ([regex]::Replace($Text, "\s+", " ")).Trim()
}

function Get-FirstParagraph {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    foreach ($paragraph in ([regex]::Split($Text.Trim(), "\r?\n\s*\r?\n"))) {
        $cleaned = Collapse-Whitespace $paragraph
        if ($cleaned) {
            return $cleaned
        }
    }

    return ""
}

function Strip-Markdown {
    param([string]$Text)

    $text = [regex]::Replace(
        $Text,
        '\[\[([^\]|]+)(?:\|([^\]]+))?\]\]',
        {
            param($match)
            if ($match.Groups[2].Value) {
                return $match.Groups[2].Value
            }
            return $match.Groups[1].Value
        }
    )
    $text = [regex]::Replace($text, '`([^`]+)`', '$1')
    $text = [regex]::Replace($text, '\*\*([^*]+)\*\*', '$1')
    $text = [regex]::Replace($text, '^#+\s*', '', 'Multiline')
    return Collapse-Whitespace $text
}

function Truncate-Text {
    param(
        [string]$Text,
        [int]$Limit = 72
    )

    if ($Text.Length -le $Limit) {
        return $Text
    }
    return $Text.Substring(0, $Limit - 1).TrimEnd() + "..."
}

function Get-SourceLink {
    param([string]$SourceRelPath)

    $fileName = Split-Path $SourceRelPath -Leaf
    $display = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    return ('[[sources/{0}|{1}]]' -f $fileName, $display)
}

function Escape-TableCell {
    param([string]$Text)

    $collapsed = Collapse-Whitespace $Text
    return $collapsed.Replace('|', '/')
}

function Load-IndexQuestions {
    param([string]$IndexPath)

    $questions = @{}
    $order = New-Object System.Collections.Generic.List[string]

    if (-not (Test-Path $IndexPath)) {
        return @{
            Questions = $questions
            Order = $order
        }
    }

    foreach ($line in ((Read-Text $IndexPath) -split '\r?\n')) {
        $match = [regex]::Match($line.Trim(), '^\|\s*\[\[([^\]]+)\]\]\s*\|\s*(.*?)\s*\|\s*(\d+)\s*\|$')
        if (-not $match.Success) {
            continue
        }
        $title = $match.Groups[1].Value.Trim()
        $questions[$title] = $match.Groups[2].Value.Trim()
        $order.Add($title)
    }

    return @{
        Questions = $questions
        Order = $order
    }
}

function Scan-Sources {
    param([string]$RootPath)

    $records = @{}
    $sourcesDir = Join-Path $RootPath "sources"

    foreach ($file in (Get-ChildItem -Path $sourcesDir -Filter *.md | Sort-Object Name)) {
        $text = Read-Text $file.FullName
        $relPath = Get-RelativePath -Base $RootPath -Path $file.FullName
        $records[$relPath] = @{
            rel_path = $relPath
            name = $file.Name
            hash = Get-TextHash $text
            mtime = $file.LastWriteTimeUtc.ToString("o")
        }
    }

    return $records
}

function Scan-Pages {
    param(
        [string]$RootPath,
        [hashtable]$IndexQuestions
    )

    $records = @{}
    $wikiDir = Join-Path $RootPath "wiki"

    foreach ($file in (Get-ChildItem -Path $wikiDir -Filter *.md | Sort-Object Name)) {
        if ($file.Name -eq "index.md") {
            continue
        }

        $text = Read-Text $file.FullName
        $parsed = Parse-Frontmatter $text
        $frontmatter = $parsed.Frontmatter
        $body = $parsed.Body
        $sections = Parse-Sections $body
        $relPath = Get-RelativePath -Base $RootPath -Path $file.FullName

        $title = $frontmatter["title"]
        if (-not $title) {
            $headingMatch = [regex]::Match($body, '(?m)^#\s+(.+)$')
            if ($headingMatch.Success) {
                $title = $headingMatch.Groups[1].Value.Trim()
            } else {
                $title = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            }
        }

        $question = $IndexQuestions[$title]
        if (-not $question) {
            $question = $frontmatter["question"]
        }
        if (-not $question) {
            $question = Strip-Markdown (Get-FirstParagraph $sections["核心洞察"])
        }
        if (-not $question) {
            $question = "待补充"
        }

        $sourceRefs = @()
        foreach ($match in ([regex]::Matches($text, '\[\[sources/([^\\\]|]+)(?:\\)?(?:\|[^\]]+)?\]\]'))) {
            $sourceRefs += "sources/$($match.Groups[1].Value)"
        }

        $records[$title] = @{
            title = $title
            rel_path = $relPath
            hash = Get-TextHash $text
            question = Truncate-Text (Escape-TableCell $question)
            source_refs = @($sourceRefs | Sort-Object -Unique)
        }
    }

    return $records
}

function Get-CitedPagesBySource {
    param([hashtable]$Pages)

    $citedBy = @{}
    foreach ($page in $Pages.Values) {
        foreach ($sourceRel in $page.source_refs) {
            if (-not $citedBy.ContainsKey($sourceRel)) {
                $citedBy[$sourceRel] = New-Object System.Collections.Generic.List[string]
            }
            $null = $citedBy[$sourceRel].Add($page.title)
        }
    }

    foreach ($sourceRel in @($citedBy.Keys)) {
        $citedBy[$sourceRel] = @($citedBy[$sourceRel] | Sort-Object)
    }

    return $citedBy
}

function Load-State {
    param([string]$StatePath)

    if (-not (Test-Path $StatePath)) {
        return @{}
    }

    return ConvertTo-PlainHashtable (ConvertFrom-Json (Read-Text $StatePath))
}

function Build-StateSnapshot {
    param(
        [hashtable]$Sources,
        [hashtable]$Pages,
        [hashtable]$Pending,
        [string]$SyncedAt
    )

    $sourceSnapshot = [ordered]@{}
    foreach ($sourceRel in @($Sources.Keys | Sort-Object)) {
        $record = $Sources[$sourceRel]
        $sourceSnapshot[$sourceRel] = @{
            hash = $record.hash
            mtime = $record.mtime
        }
    }

    $pageSnapshot = [ordered]@{}
    foreach ($title in @($Pages.Keys | Sort-Object)) {
        $record = $Pages[$title]
        $pageSnapshot[$title] = @{
            path = $record.rel_path
            hash = $record.hash
            source_refs = $record.source_refs
        }
    }

    return [ordered]@{
        version = 1
        last_synced = $SyncedAt
        sources = $sourceSnapshot
        pages = $pageSnapshot
        pending = $Pending
    }
}

function Write-State {
    param(
        [string]$StatePath,
        [hashtable]$Snapshot
    )

    Write-Text -Path $StatePath -Content (($Snapshot | ConvertTo-Json -Depth 10) + "`n")
}

function Build-Pending {
    param(
        [hashtable]$PreviousState,
        [hashtable]$Sources,
        [hashtable]$Pages,
        [string[]]$ChangedSources,
        [string]$SyncedAt
    )

    $previousPending = @{}
    if ($PreviousState.ContainsKey("pending")) {
        $previousPending = $PreviousState["pending"]
    }

    $previousPages = @{}
    if ($PreviousState.ContainsKey("pages")) {
        $previousPages = $PreviousState["pages"]
    }

    $uncitedSources = @{}
    if ($previousPending.ContainsKey("uncited_sources")) {
        $uncitedSources = $previousPending["uncited_sources"]
    }

    $stalePages = @{}
    if ($previousPending.ContainsKey("stale_pages")) {
        $stalePages = $previousPending["stale_pages"]
    }

    $citedBy = Get-CitedPagesBySource $Pages
    $nextUncited = @{}
    $nextStale = @{}

    foreach ($sourceRel in @($uncitedSources.Keys)) {
        if (-not $Sources.ContainsKey($sourceRel)) {
            continue
        }
        if ($citedBy.ContainsKey($sourceRel)) {
            continue
        }
        $entry = $uncitedSources[$sourceRel]
        $nextUncited[$sourceRel] = @{
            detected_at = $entry["detected_at"]
            source_hash = $Sources[$sourceRel].hash
        }
    }

    foreach ($pageTitle in @($stalePages.Keys)) {
        if (-not $Pages.ContainsKey($pageTitle)) {
            continue
        }

        $page = $Pages[$pageTitle]
        $pageEntry = $stalePages[$pageTitle]
        $previousPageHash = ""
        if ($previousPages.ContainsKey($pageTitle)) {
            $previousPageHash = $previousPages[$pageTitle]["hash"]
        }

        $keptSources = @{}
        foreach ($sourceRel in @($pageEntry["sources"].Keys)) {
            if (-not $Sources.ContainsKey($sourceRel)) {
                continue
            }
            if ($page.source_refs -notcontains $sourceRel) {
                continue
            }
            if ($page.hash -ne $previousPageHash) {
                continue
            }

            $sourceEntry = $pageEntry["sources"][$sourceRel]
            $keptSources[$sourceRel] = @{
                detected_at = $sourceEntry["detected_at"]
                source_hash = $Sources[$sourceRel].hash
                page_hash_at_detection = $sourceEntry["page_hash_at_detection"]
            }
        }

        if ($keptSources.Count -gt 0) {
            $nextStale[$pageTitle] = @{
                sources = $keptSources
            }
        }
    }

    foreach ($sourceRel in $ChangedSources) {
        $relatedPages = @()
        if ($citedBy.ContainsKey($sourceRel)) {
            $relatedPages = $citedBy[$sourceRel]
        }

        if ($relatedPages.Count -eq 0) {
            $nextUncited[$sourceRel] = @{
                detected_at = $SyncedAt
                source_hash = $Sources[$sourceRel].hash
            }
            continue
        }

        foreach ($pageTitle in $relatedPages) {
            if (-not $nextStale.ContainsKey($pageTitle)) {
                $nextStale[$pageTitle] = @{
                    sources = @{}
                }
            }

            $nextStale[$pageTitle]["sources"][$sourceRel] = @{
                detected_at = $SyncedAt
                source_hash = $Sources[$sourceRel].hash
                page_hash_at_detection = $Pages[$pageTitle].hash
            }
        }
    }

    $sortedUncited = [ordered]@{}
    foreach ($sourceRel in @($nextUncited.Keys | Sort-Object)) {
        $sortedUncited[$sourceRel] = $nextUncited[$sourceRel]
    }

    $sortedStale = [ordered]@{}
    foreach ($pageTitle in @($nextStale.Keys | Sort-Object)) {
        $sortedSources = [ordered]@{}
        foreach ($sourceRel in @($nextStale[$pageTitle]["sources"].Keys | Sort-Object)) {
            $sortedSources[$sourceRel] = $nextStale[$pageTitle]["sources"][$sourceRel]
        }
        $sortedStale[$pageTitle] = @{
            sources = $sortedSources
        }
    }

    return @{
        uncited_sources = $sortedUncited
        stale_pages = $sortedStale
    }
}

function Render-SyncInbox {
    param([hashtable]$Pending)

    $lines = @(
        "## Sync Inbox",
        "",
        "> 这个区块由 `sync-wiki` 自动维护。它只提示增量，不替你判断什么值得写成新页。",
        ""
    )

    $uncitedSources = @{}
    if ($Pending.ContainsKey("uncited_sources")) {
        $uncitedSources = $Pending["uncited_sources"]
    }

    $stalePages = @{}
    if ($Pending.ContainsKey("stale_pages")) {
        $stalePages = $Pending["stale_pages"]
    }

    if ($uncitedSources.Count -eq 0 -and $stalePages.Count -eq 0) {
        $lines += "当前没有待处理增量。"
        return ($lines -join "`n")
    }

    if ($uncitedSources.Count -gt 0) {
        $lines += @("### Uncited Sources", "")
        foreach ($sourceRel in @($uncitedSources.Keys | Sort-Object)) {
            $detectedAt = $uncitedSources[$sourceRel]["detected_at"]
            $date = if ($detectedAt.Length -ge 10) { $detectedAt.Substring(0, 10) } else { $detectedAt }
            $lines += ('- {0} (detected {1})' -f (Get-SourceLink $sourceRel), $date)
        }
        $lines += ""
    }

    if ($stalePages.Count -gt 0) {
        $lines += @("### Pages To Revisit", "")
        foreach ($pageTitle in @($stalePages.Keys | Sort-Object)) {
            $sourceLinks = @()
            foreach ($sourceRel in @($stalePages[$pageTitle]["sources"].Keys | Sort-Object)) {
                $sourceLinks += Get-SourceLink $sourceRel
            }
            $lines += ('- [[{0}]] <- {1}' -f $pageTitle, ($sourceLinks -join ', '))
        }
        $lines += ""
    }

    return (($lines | Where-Object { $_ -ne $null }) -join "`n").TrimEnd()
}

function Render-Index {
    param(
        [hashtable]$Pages,
        [System.Collections.Generic.List[string]]$ExistingOrder,
        [hashtable]$Pending
    )

    $today = Get-Date -Format "yyyy-MM-dd"
    $orderedTitles = New-Object System.Collections.Generic.List[string]

    foreach ($title in $ExistingOrder) {
        if ($Pages.ContainsKey($title) -and -not $orderedTitles.Contains($title)) {
            $orderedTitles.Add($title)
        }
    }

    foreach ($title in @($Pages.Keys | Sort-Object)) {
        if (-not $orderedTitles.Contains($title)) {
            $orderedTitles.Add($title)
        }
    }

    $lines = @(
        "---",
        "title: Wiki Index",
        "updated: $today",
        "---",
        "# Wiki",
        "",
        "这个 wiki 不是文章摘要的集合。每一页回答一个跨多篇原始材料的真问题。",
        "",
        "## Pages",
        "",
        "| Page | Question | Sources |",
        "|------|----------|---------|"
    )

    foreach ($title in $orderedTitles) {
        $page = $Pages[$title]
        $lines += ('| [[{0}]] | {1} | {2} |' -f $title, $page.question, $page.source_refs.Count)
    }

    $lines += ""
    $lines += Render-SyncInbox $Pending
    $lines += ""

    return ($lines -join "`n")
}

function Detect-ChangedSources {
    param(
        [hashtable]$PreviousState,
        [hashtable]$Sources
    )

    $previousSources = @{}
    if ($PreviousState.ContainsKey("sources")) {
        $previousSources = $PreviousState["sources"]
    }

    $changed = @()
    foreach ($sourceRel in @($Sources.Keys | Sort-Object)) {
        $previousHash = $null
        if ($previousSources.ContainsKey($sourceRel)) {
            $previousHash = $previousSources[$sourceRel]["hash"]
        }
        if ($previousHash -ne $Sources[$sourceRel].hash) {
            $changed += $sourceRel
        }
    }

    return $changed
}

$rootPath = (Resolve-Path $Root).Path
$statePath = Join-Path $rootPath ".wiki-state.json"
$indexPath = Join-Path $rootPath "wiki\index.md"
$syncedAt = [DateTime]::UtcNow.ToString("o")

$indexData = Load-IndexQuestions $indexPath
$sources = Scan-Sources $rootPath
$pages = Scan-Pages -RootPath $rootPath -IndexQuestions $indexData.Questions
$previousState = Load-State $statePath

if ($previousState.Count -eq 0) {
    $pending = @{
        uncited_sources = [ordered]@{}
        stale_pages = [ordered]@{}
    }
    $snapshot = Build-StateSnapshot -Sources $sources -Pages $pages -Pending $pending -SyncedAt $syncedAt
    Write-State -StatePath $statePath -Snapshot $snapshot
    $bootstrapped = $true
    $changedSources = @()
} else {
    $changedSources = Detect-ChangedSources -PreviousState $previousState -Sources $sources
    $pending = Build-Pending -PreviousState $previousState -Sources $sources -Pages $pages -ChangedSources $changedSources -SyncedAt $syncedAt
    $snapshot = Build-StateSnapshot -Sources $sources -Pages $pages -Pending $pending -SyncedAt $syncedAt
    Write-State -StatePath $statePath -Snapshot $snapshot
    $bootstrapped = $false
}

$indexContent = Render-Index -Pages $pages -ExistingOrder $indexData.Order -Pending $snapshot.pending
Write-Text -Path $indexPath -Content ($indexContent + "`n")

if ($bootstrapped) {
    Write-Output "Bootstrapped .wiki-state.json from current sources. No existing source was queued as pending."
} else {
    $uncitedCount = $snapshot.pending.uncited_sources.Count
    $stalePageCount = $snapshot.pending.stale_pages.Count
    Write-Output "Synced wiki: changed_sources=$(@($changedSources).Count) uncited_sources=$uncitedCount stale_pages=$stalePageCount"
}



