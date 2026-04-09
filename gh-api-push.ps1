# gh-api-push.ps1
# Uses GitHub API to push files without git push (bypasses TCP 443 block)
$ErrorActionPreference = 'Stop'
$repo = "jm6-lang/foss-nav"
$baseUrl = "https://api.github.com/repos/$repo"
$headers = @{
    "Authorization" = "Bearer $(gh auth token)"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# Get current branch SHA
$refResp = Invoke-RestMethod -Uri "$baseUrl/git/refs/heads/main" -Headers $headers -Method GET
$currentSha = $refResp.object.sha
Write-Host "Current branch SHA: $currentSha"

# Read all files from src/ and public/
$files = @()
Get-ChildItem -Path "src", "public" -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($_.FullName.IndexOf("\src\") + 5)
    if ($relativePath.StartsWith("src\")) { $relativePath = $relativePath.Substring(4) }
    if ($relativePath.StartsWith("public\")) { $relativePath = $relativePath.Substring(7) }
    $files += [PSCustomObject]@{
        Path = $relativePath
        FullPath = $_.FullName
    }
}
# Add root files
foreach ($f in @("package.json", "astro.config.mjs", "tsconfig.json", "README.md")) {
    if (Test-Path $f) {
        $files += [PSCustomObject]@{
            Path = $f
            FullPath = (Resolve-Path $f).Path
        }
    }
}

Write-Host "Total files to push: $($files.Count)"
Write-Host "Files: $($files.Path -join ', ')"

# Read public/favicon.svg
if (Test-Path "public/favicon.svg") {
    $files += [PSCustomObject]@{
        Path = "public/favicon.svg"
        FullPath = (Resolve-Path "public/favicon.svg").Path
    }
}

# Build tree
$treeItems = @()
foreach ($f in $files) {
    $content = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($f.FullPath))
    # Detect content type
    if ($f.Path -match "\.(tsx?|jsx?)$") { $encoding = "base64"; $type = "file" }
    elseif ($f.Path -match "\.(svg|jpg|png|gif|ico|webp|woff2?)$") { $encoding = "base64"; $type = "file" }
    else { $encoding = "base64"; $type = "file" }
    
    $treeItems += @{
        path = $f.Path -replace "\\", "/"
        mode = "100644"
        type = $type
        content_b64 = $content
    }
}

# Create tree
$treeBody = @{ base_tree = $currentSha; tree = $treeItems } | ConvertTo-Json -Depth 10
$treeResp = Invoke-RestMethod -Uri "$baseUrl/git/trees" -Headers $headers -Method POST -Body $treeBody -ContentType "application/json"
Write-Host "Tree SHA: $($treeResp.sha)"
Write-Host "Tree URL: $($treeResp.url)"

# Create commit
$commitMsg = "feat: initial FreeOpen project — 50+ tools, 10 categories, Astro+React"
$commitBody = @{
    message = $commitMsg
    tree = $treeResp.sha
    parents = @($currentSha)
} | ConvertTo-Json
$commitResp = Invoke-RestMethod -Uri "$baseUrl/git/commits" -Headers $headers -Method POST -Body $commitBody -ContentType "application/json"
Write-Host "Commit SHA: $($commitResp.sha)"

# Update branch ref
$refBody = @{ sha = $commitResp.sha; force = $true } | ConvertTo-Json
Invoke-RestMethod -Uri "$baseUrl/git/refs/heads/main" -Headers $headers -Method PATCH -Body $refBody -ContentType "application/json"
Write-Host "Branch updated successfully!"
Write-Host "Repository: https://github.com/$repo"
