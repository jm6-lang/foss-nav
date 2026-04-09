# gh-push-all.ps1 - Push all project files via GitHub API (no git push needed)
$ErrorActionPreference = 'Stop'
$headers = @{
    "Authorization" = "Bearer $(gh auth token)"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}
$repo = "jm6-lang/foss-nav"
$baseUrl = "https://api.github.com/repos/$repo"
$projectRoot = "C:\Users\Administrator\.qclaw\workspace-agent-3bb7b585\foss-nav"

# Base tree SHA (from initial commit)
$baseTreeSha = "c24a93fc4e822e4d75c4bbeaa63268092a88a143"

# Collect all files
$allFiles = @()
foreach ($path in @("package.json", "astro.config.mjs", "tsconfig.json", "README.md")) {
    $fullPath = Join-Path $projectRoot $path
    if (Test-Path $fullPath) {
        $allFiles += @{ path = $path; fullPath = $fullPath }
    }
}
foreach ($f in Get-ChildItem -Path "$projectRoot\src" -Recurse -File) {
    $relativePath = $f.FullName.Substring($projectRoot.Length + 5).Replace("\", "/")
    $allFiles += @{ path = $relativePath; fullPath = $f.FullName }
}
foreach ($f in Get-ChildItem -Path "$projectRoot\public" -Recurse -File) {
    $relativePath = $f.FullName.Substring($projectRoot.Length + 8).Replace("\", "/")
    $allFiles += @{ path = $relativePath; fullPath = $f.FullName }
}

Write-Host "Uploading $($allFiles.Count) files..."
$blobShas = @{}

foreach ($file in $allFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($file.fullPath)
    $content = [Convert]::ToBase64String($bytes)
    $body = @{
        message = "upload $script:fname"
        content = $content
    } | ConvertTo-Json -Compress
    $body = $body -replace '"content"\s*:\s*"', '"content": "'  # keep base64 as-is

    $resp = Invoke-RestMethod -Uri "$baseUrl/contents/$($file.path)" `
        -Headers $headers -Method PUT `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
        -ContentType "application/json"
    $blobShas[$file.path] = $resp.content.sha
    Write-Host "  ✓ $($file.path)"
}

Write-Host "All files uploaded. Committing..."

# Build tree items
$treeItems = @()
foreach ($file in $allFiles) {
    $treeItems += @{
        path = $file.path
        mode = "100644"
        type = "blob"
        sha = $blobShas[$file.path]
    }
}

$treeBody = @{ base_tree = $baseTreeSha; tree = $treeItems } | ConvertTo-Json -Depth 10
$treeResp = Invoke-RestMethod -Uri "$baseUrl/git/trees" -Headers $headers -Method POST `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($treeBody)) `
    -ContentType "application/json"

Write-Host "Tree created: $($treeResp.sha)"

# Create commit
$commitBody = @{
    message = "feat: initial FreeOpen project — 50+ tools, 10 categories, Astro+React"
    tree = $treeResp.sha
    parents = @("3a743f2759b2c0e345a5a41c44405ea1b564eb70")
} | ConvertTo-Json
$commitResp = Invoke-RestMethod -Uri "$baseUrl/git/commits" -Headers $headers -Method POST `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($commitBody)) `
    -ContentType "application/json"

Write-Host "Commit created: $($commitResp.sha)"

# Update branch
$refBody = @{ sha = $commitResp.sha; force = $true } | ConvertTo-Json
Invoke-RestMethod -Uri "$baseUrl/git/refs/heads/main" -Headers $headers -Method PATCH `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($refBody)) `
    -ContentType "application/json"

Write-Host ""
Write-Host "✅ Done! https://github.com/jm6-lang/foss-nav"
