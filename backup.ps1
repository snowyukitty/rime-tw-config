# Rime one-click backup: sync userdb -> git commit -> push to GitHub
# Usage: double-click backup.cmd, or run  powershell -File backup.ps1
# (ASCII-only on purpose, so Windows PowerShell 5.1 parses it under any codepage.)
#
# Why this stops WeaselServer before syncing:
#   The running WeaselServer holds a lock on the userdb (LevelDB). A separate
#   "WeaselDeployer.exe /sync" process then cannot open/export the userdb and
#   fails SILENTLY (snapshot is never updated). So we quit the server, sync,
#   then restart it. The deployer is located via the registry (WeaselRoot),
#   not a hard-coded path, because Weasel may be installed on any drive.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# --- 1) Locate Weasel install (deployer + server) ---------------------------
function Get-WeaselRoot {
    foreach ($key in 'HKLM:\SOFTWARE\WOW6432Node\Rime\Weasel', 'HKLM:\SOFTWARE\Rime\Weasel') {
        try {
            $r = (Get-ItemProperty -Path $key -ErrorAction Stop).WeaselRoot
            if ($r -and (Test-Path $r)) { return $r }
        } catch { }
    }
    # fallback: scan common install locations for a folder that has the deployer
    foreach ($glob in 'C:\Program Files\Rime\weasel-*', 'C:\Program Files (x86)\Rime\weasel-*', 'D:\Software\System\Rime\weasel-*') {
        $d = Get-ChildItem -Path $glob -Directory -ErrorAction SilentlyContinue |
             Where-Object { Test-Path (Join-Path $_.FullName 'WeaselDeployer.exe') } |
             Sort-Object Name | Select-Object -Last 1
        if ($d) { return $d.FullName }
    }
    return $null
}

$root     = Get-WeaselRoot
$deployer = if ($root) { Join-Path $root 'WeaselDeployer.exe' } else { $null }
$server   = if ($root) { Join-Path $root 'WeaselServer.exe' }   else { $null }
$syncDir  = Join-Path $PSScriptRoot 'rime-sync'

function Get-NewestSnapshotTime {
    if (-not (Test-Path $syncDir)) { return $null }
    $f = Get-ChildItem -Path $syncDir -Recurse -Filter '*.userdb.txt' -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime | Select-Object -Last 1
    if ($f) { return $f.LastWriteTime } else { return $null }
}

# Graceful "/q" quit, then poll until the process is gone (force-kill as last
# resort). We do NOT use "Start-Process /q -Wait": the launched quit-helper may
# not exit and that hangs the whole backup.
function Stop-WeaselServer {
    param([string]$exe)
    if (-not (Get-Process -Name WeaselServer -ErrorAction SilentlyContinue)) { return }
    if ($exe -and (Test-Path $exe)) { Start-Process -FilePath $exe -ArgumentList '/q' | Out-Null }
    for ($i = 0; $i -lt 20; $i++) {
        if (-not (Get-Process -Name WeaselServer -ErrorAction SilentlyContinue)) { return }
        Start-Sleep -Milliseconds 500
    }
    Stop-Process -Name WeaselServer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# --- 2) Sync userdb (stop server to release the lock, then restart) ---------
if ($deployer -and (Test-Path $deployer)) {
    $before = Get-NewestSnapshotTime
    $serverWasRunning = [bool](Get-Process -Name WeaselServer -ErrorAction SilentlyContinue)
    try {
        if ($serverWasRunning -and $server -and (Test-Path $server)) {
            Write-Host '-> Stopping WeaselServer to release userdb lock...' -ForegroundColor Cyan
            Stop-WeaselServer -exe $server
        }
        Write-Host '-> Syncing Rime userdb...' -ForegroundColor Cyan
        $proc = Start-Process -FilePath $deployer -ArgumentList '/sync' -PassThru
        $proc | Wait-Process -Timeout 60 -ErrorAction SilentlyContinue
        if (-not $proc.HasExited) { Write-Warning 'WeaselDeployer /sync did not finish in 60s; continuing.' }
        Start-Sleep -Seconds 3
    } finally {
        # always bring the IME back, even if sync above threw
        if ($serverWasRunning -and $server -and (Test-Path $server)) {
            Write-Host '-> Restarting WeaselServer...' -ForegroundColor Cyan
            Start-Process -FilePath $server
        }
    }
    $after = Get-NewestSnapshotTime
    if ($before -and $after -and $after -gt $before) {
        Write-Host '   userdb snapshot updated.' -ForegroundColor Green
    } elseif ($null -eq $after) {
        Write-Warning 'No userdb snapshot found after sync; check sync_dir in installation.yaml.'
    } else {
        Write-Host '   userdb snapshot unchanged (no new words since last sync).' -ForegroundColor Yellow
    }
} else {
    Write-Warning 'WeaselDeployer.exe not found (checked registry + common paths); skipping sync, committing existing files only.'
}

# --- 3) Commit + push only if there are changes -----------------------------
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
