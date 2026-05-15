$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
Set-Location $scriptDir
[System.IO.Directory]::SetCurrentDirectory($scriptDir)
$Host.UI.RawUI.WindowTitle = "AuraHub Restore"
$enc = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host "    AuraHub -- Restore from Backup" -ForegroundColor Cyan
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host ""

# Locate backup folder
$backupDir = Join-Path $env:USERPROFILE "Documents\AuraHubBackup"
if (-not (Test-Path $backupDir)) {
    Write-Host "  ERROR: Backup folder not found:" -ForegroundColor Red
    Write-Host "  $backupDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Run SyncAuraHub.bat at least once to create a backup." -ForegroundColor Yellow
    Read-Host "  Press Enter to exit"; exit 1
}

$backups = @(Get-ChildItem $backupDir -Filter "AuraHub_*.lua" | Sort-Object Name -Descending)
if ($backups.Count -eq 0) {
    Write-Host "  No backups found in:" -ForegroundColor Yellow
    Write-Host "  $backupDir" -ForegroundColor Yellow
    Read-Host "  Press Enter to exit"; exit 1
}

# Show available backups
Write-Host "  Available backups ($($backups.Count)):" -ForegroundColor White
for ($i = 0; $i -lt $backups.Count; $i++) {
    $b   = $backups[$i]
    $sz  = [math]::Round($b.Length / 1KB, 1)
    $tag = if ($i -eq 0) { " <-- latest" } else { "" }
    $col = if ($i -eq 0) { "Cyan" } else { "DarkGray" }
    Write-Host ("  [{0}] {1}  ({2} KB){3}" -f ($i + 1), $b.Name, $sz, $tag) -ForegroundColor $col
}
Write-Host ""

$choice = Read-Host "  Enter number to restore (default: 1 = latest)"
if ($choice -eq "") { $choice = "1" }
$idx = 0
if (-not [int]::TryParse($choice, [ref]$idx) -or $idx -lt 1 -or $idx -gt $backups.Count) {
    Write-Host "  Invalid choice. Cancelled." -ForegroundColor Red
    Read-Host "  Press Enter to exit"; exit 1
}
$chosen = $backups[$idx - 1]
Write-Host ""
Write-Host "  Selected: $($chosen.Name)" -ForegroundColor Cyan

# Locate WTF accounts
$wtf = "WTF\Account"
if (-not (Test-Path $wtf)) {
    Write-Host ""
    Write-Host "  WTF\Account not found." -ForegroundColor Yellow
    Write-Host "  Make sure to run this script from the WoW folder, or run WoW once first" -ForegroundColor Yellow
    Write-Host "  so it creates the WTF folder structure." -ForegroundColor Yellow
    Read-Host "  Press Enter to exit"; exit 1
}

$accounts = @(Get-ChildItem $wtf -Directory | Select-Object -ExpandProperty Name)
if ($accounts.Count -eq 0) {
    Write-Host "  No accounts found under WTF\Account." -ForegroundColor Yellow
    Write-Host "  Log into WoW once first so the account folders are created." -ForegroundColor Yellow
    Read-Host "  Press Enter to exit"; exit 1
}

Write-Host ""
Write-Host "  Will restore to $($accounts.Count) account(s):" -ForegroundColor White
foreach ($acc in $accounts) { Write-Host "    - $acc" -ForegroundColor DarkGray }
Write-Host ""

$confirm = Read-Host "  Continue? (Y/N)"
if ($confirm -notmatch '^[Yy]') {
    Write-Host "  Cancelled."; Read-Host "  Press Enter"; exit 0
}
Write-Host ""

$content = [System.IO.File]::ReadAllText($chosen.FullName, $enc)
$ok = 0
foreach ($acc in $accounts) {
    $dir  = "WTF\Account\$acc\SavedVariables"
    $path = "$dir\AuraHub.lua"
    try {
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        if (Test-Path $path) { Copy-Item $path ($path + ".bak") -Force }
        [System.IO.File]::WriteAllText($path, $content, $enc)
        Write-Host "    OK  $acc" -ForegroundColor Green
        $ok++
    } catch {
        Write-Host "    FAIL  $acc  --  $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "  Done! Restored to $ok account(s)." -ForegroundColor Green
Write-Host "  Log in to WoW -- all saved profiles are now available." -ForegroundColor Cyan
Write-Host "  Previous files backed up as .bak in each account folder." -ForegroundColor DarkGray
Write-Host ""
Read-Host "  Press Enter to close"
