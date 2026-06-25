# Rime one-click backup: sync userdb -> git commit -> push to GitHub
# Usage: double-click backup.cmd, or run  powershell -File backup.ps1
# (ASCII-only on purpose, so Windows PowerShell 5.1 parses it under any codepage.)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# 1) Locate newest WeaselDeployer and sync Rime userdb into rime-sync/
$deployer = Get-ChildItem 'C:\Program Files\Rime\weasel-*\WeaselDeployer.exe' -ErrorAction SilentlyContinue |
            Sort-Object FullName | Select-Object -Last 1
if ($deployer) {
    Write-Host '-> Syncing Rime userdb...' -ForegroundColor Cyan
    Start-Process $deployer.FullName -ArgumentList '/sync' -Wait
} else {
    Write-Warning 'WeaselDeployer.exe not found; skipping sync, committing existing files only.'
}

# 2) Commit + push only if there are changes
git add -A
if (git status --porcelain) {
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
    git commit -q -m "backup: Rime userdb + config $stamp"
    Write-Host '-> Pushing to GitHub...' -ForegroundColor Cyan
    git push -q origin HEAD
    Write-Host "[OK] Backup complete $stamp" -ForegroundColor Green
} else {
    Write-Host '[OK] No changes; already up to date.' -ForegroundColor Yellow
}
