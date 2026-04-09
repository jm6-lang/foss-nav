$ErrorActionPreference = 'Stop'
$headers = @{ Authorization = "Bearer $(gh auth token)"; Accept = "application/vnd.github+json"; "X-GitHub-Api-Version" = "2022-11-28" }
$baseUrl = "https://api.github.com/repos/jm6-lang/foss-nav"
$projectRoot = "C:\Users\Administrator\.qclaw\workspace-agent-3bb7b585\foss-nav"

# Get initial commit SHA
$initCommit = gh api repos/jm6-lang/foss-nav/git/refs/heads/main --jq '.object.sha'
$baseTree = gh api repos/jm6-lang/foss-nav/git/commits/$initCommit --jq '.tree.sha'
Write-Host "Base tree: $baseTree"

# Collect files
$allFiles = @()
foreach ($p in @("package.json", "astro.config.mjs", "tsconfig.json", "README.md")) {
    $f = Join-Path $projectRoot $p
    if (Test-Path $f) { $allFiles += $f }
}
Get-ChildItem "$projectRoot\src" -Recurse -File | % { $allFiles += $_.FullName }
Get-ChildItem "$projectRoot\public" -Recurse -File | % { $allFiles += $_.FullName }

Write-Host "Files to upload: $($allFiles.Count)"

# Upload each file and collect blobs
$blobs = @()
foreach ($file in $allFiles) {
    $relPath = $file.Substring($projectRoot.Length + 1).Replace("\", "/")
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $b64 = [Convert]::ToBase64String($bytes)
    $blob = gh api repos/jm6-lang/foss-nav/git/blobs --method POST `
        -f content=$b64 -f encoding="base64" --jq '.sha'
    $blobs += @{ path = $relPath; sha = $blob }
    Write-Host "  ✓ $relPath"
}

Write-Host "Creating tree..."
$treeJson = ($blobs | % { @{ path = $_.path; mode = "100644"; type = "blob"; sha = $_.sha } } | ConvertTo-Json -Depth 5)
$treeBody = @{ base_tree = $baseTree; tree = $blobs | % { @{ path = $_.path; mode = "100644"; type = "blob"; sha = $_.sha } } } | ConvertTo-Json -Depth 6
$treeSha = gh api repos/jm6-lang/foss-nav/git/trees --method POST -f base_tree=$baseTree `
    -f tree=($blobs | % { @{ path = $_.path; mode = "100644"; type = "blob"; sha = $_.sha } } | ConvertTo-Json -Compress) --jq '.sha'

Write-Host "Tree SHA: $treeSha"

$commitSha = gh api repos/jm6-lang/foss-nav/git/commits --method POST `
    -f message="feat: initial FreeOpen project — 50+ tools, 10 categories, Astro+React" `
    -f tree=$treeSha -f parents=$initCommit --jq '.sha'

Write-Host "Commit SHA: $commitSha"

# Force-push branch
gh api repos/jm6-lang/foss-nav/git/refs/heads/main --method PATCH -f sha=$commitSha -f force=$true | Out-Null

Write-Host ""
Write-Host "✅ Push complete! https://github.com/jm6-lang/foss-nav"
