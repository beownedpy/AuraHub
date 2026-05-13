$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
Set-Location $scriptDir
[System.IO.Directory]::SetCurrentDirectory($scriptDir)
$Host.UI.RawUI.WindowTitle = "AuraHub Merge"
$enc = [System.Text.Encoding]::UTF8

# Parse all sections from a file in one pass, return hashtable sec -> List<string[]>
function Parse-All([string]$content, [string[]]$sections) {
    $result = @{}
    foreach ($s in $sections) { $result[$s] = [System.Collections.Generic.List[string[]]]::new() }

    $lines  = $content -split '\r?\n'
    $curSec = $null
    $inEnt  = $false
    $buf    = [System.Collections.Generic.List[string]]::new()

    foreach ($line in $lines) {
        if ($curSec -eq $null) {
            foreach ($s in $sections) {
                if ($line -match "^\t\[`"$s`"\] = \{") { $curSec = $s; break }
            }
            continue
        }
        if ($line -match '^\t\}') { $curSec = $null; continue }
        if (-not $inEnt -and $line -match '^\t\t\{') {
            $inEnt = $true; $buf.Clear(); $buf.Add($line); continue
        }
        if ($inEnt) {
            $buf.Add($line)
            if ($line -match '^\t\t\}') {
                $result[$curSec].Add($buf.ToArray()); $buf.Clear(); $inEnt = $false
            }
        }
    }
    return $result
}

function Get-Name([string[]]$e) {
    foreach ($l in $e) {
        # Match only top-level entry fields (3 tabs), not nested table fields
        if ($l -match '^\t\t\t\["name"\] = "([^"]+)"') { return $Matches[1] }
    }
    return $null
}

# Read tombstones for one section from a file.
# Returns hashtable: name -> unix timestamp of deletion.
# If an entry's savedAt > tombstone timestamp it was re-saved after deletion and survives.
function Get-Tombstones([string]$content, [string]$section) {
    $ts    = @{}
    $lines = $content -split '\r?\n'
    $state = 0  # 0=root  1=in _deleted  2=in _deleted[section]

    foreach ($line in $lines) {
        if ($state -eq 0) {
            if ($line -match '^\t\["_deleted"\] = \{') { $state = 1 }
        } elseif ($state -eq 1) {
            if ($line -match "^\t\t\[`"$section`"\] = \{") { $state = 2; continue }
            if ($line -match '^\t\}') { return $ts }
        } else {
            if ($line -match '^\t\t\}') { return $ts }
            if ($line -match '^\t\t\t\["([^"]+)"\] = (\d+)') {
                $n = $Matches[1]; $t = [long]$Matches[2]
                if (-not $ts.ContainsKey($n) -or $t -gt $ts[$n]) { $ts[$n] = $t }
            }
        }
    }
    return $ts
}

function Get-SavedAt([string[]]$e) {
    foreach ($l in $e) {
        if ($l -match '^\t\t\t\["savedAt"\] = (\d+)') { return [long]$Matches[1] }
    }
    return 0
}

# For WeakAuras: extract uid (stable unique ID assigned by WA, never changes)
# uid lives directly under ["data"] = 4 tabs deep
function Get-UID([string[]]$e) {
    foreach ($l in $e) {
        if ($l -match '^\t\t\t\t\["uid"\] = "([^"]+)"') { return $Matches[1] }
    }
    return $null
}

# Rebuild base file replacing section content with merged entries (one pass).
# Sections present in base are replaced in-place.
# Sections missing from base but with merged entries are appended before the
# closing } of AuraHubDB so data added by newer addon versions is never lost.
function Rebuild-Base([string]$base, [hashtable]$merged, [string[]]$sections) {
    $lines        = $base -split '\r?\n'
    $out          = [System.Collections.Generic.List[string]]::new()
    $curSec       = $null
    $foundSections = @{}

    foreach ($line in $lines) {
        if ($curSec -eq $null) {
            $matched = $false
            foreach ($s in $sections) {
                if ($line -match "^\t\[`"$s`"\] = \{") {
                    $curSec = $s; $matched = $true
                    $foundSections[$s] = $true
                    $out.Add($line)
                    foreach ($e in $merged[$s]) {
                        foreach ($el in $e) { $out.Add($el) }
                    }
                    break
                }
            }
            if (-not $matched) { $out.Add($line) }
            continue
        }
        if ($line -match '^\t\}') {
            $curSec = $null; $out.Add($line); continue
        }
        # skip old section content (already replaced above)
    }

    # Append sections not found in the base file (e.g. new sections from addon updates)
    # Find the last bare "}" line that closes the AuraHubDB table
    $insertIdx = -1
    for ($i = $out.Count - 1; $i -ge 0; $i--) {
        if ($out[$i] -match '^\}') { $insertIdx = $i; break }
    }

    if ($insertIdx -ge 0) {
        $toInsert = [System.Collections.Generic.List[string]]::new()
        foreach ($s in $sections) {
            if (-not $foundSections.ContainsKey($s) -and $merged[$s].Count -gt 0) {
                $toInsert.Add("`t[`"$s`"] = {")
                foreach ($e in $merged[$s]) {
                    foreach ($el in $e) { $toInsert.Add($el) }
                }
                $toInsert.Add("`t},")
            }
        }
        for ($i = $toInsert.Count - 1; $i -ge 0; $i--) {
            $out.Insert($insertIdx, $toInsert[$i])
        }
    }

    return $out -join "`r`n"
}

# ─────────────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host "    AuraHub -- Smart Merge" -ForegroundColor Cyan
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host ""

$wtf = "WTF\Account"
if (-not (Test-Path $wtf)) {
    Write-Host "  ERROR: WTF\Account not found. Run from the WoW folder." -ForegroundColor Red
    Read-Host "  Press Enter to exit"; exit 1
}

$accounts = @(
    Get-ChildItem $wtf -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName "SavedVariables\AuraHub.lua") } |
    Select-Object -ExpandProperty Name
)

if ($accounts.Count -lt 2) {
    Write-Host "  Found $($accounts.Count) account(s) -- need at least 2." -ForegroundColor Yellow
    Read-Host "  Press Enter to exit"; exit 1
}

Write-Host "  Accounts found ($($accounts.Count)):" -ForegroundColor White
foreach ($acc in $accounts) {
    $sz  = [math]::Round((Get-Item "WTF\Account\$acc\SavedVariables\AuraHub.lua").Length / 1KB, 1)
    $col = if ($sz -gt 1) { "Cyan" } else { "DarkGray" }
    Write-Host "    - $acc  ($sz KB)" -ForegroundColor $col
}
Write-Host ""
Write-Host "  All accounts will be merged. Nothing is lost." -ForegroundColor Gray
Write-Host "  Identical entries deduplicated; same-name different-content both kept." -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "  Continue? (Y/N)"
if ($confirm -notmatch '^[Yy]') {
    Write-Host "  Cancelled."; Read-Host "  Press Enter"; exit 0
}
Write-Host ""

$sections = @("WeakAuras", "ElvUI", "Skada", "Binds", "Macros", "ActionBars")

# Read only non-empty files for parsing; remember base template from first account
Write-Host "  Reading files..." -ForegroundColor Gray
$raw  = @{}
$base = $null
foreach ($acc in $accounts) {
    $path = "WTF\Account\$acc\SavedVariables\AuraHub.lua"
    $content = [System.IO.File]::ReadAllText($path, $enc)
    $sz = (Get-Item $path).Length
    if ($sz -gt 1024) {
        $raw[$acc] = $content
        if ($base -eq $null) { $base = $content }
    } elseif ($base -eq $null) {
        $base = $content   # fallback: use empty file as template
    }
}

if ($raw.Count -eq 0) {
    Write-Host "  No accounts have saved data yet." -ForegroundColor Yellow
    Read-Host "  Press Enter to exit"; exit 1
}

# Deduplication keys:
# WeakAuras -> uid field (stable WA-assigned ID, survives WoW re-serialization)
# ElvUI/Skada/Binds/Macros -> name field (profile name, user-assigned)
# Fallback -> index in insertion order (no key found, always keep)
# When same key seen twice, keep the entry with higher savedAt (most recent wins)

Write-Host "  Parsing..." -ForegroundColor Gray
$mergedByKey = @{}
foreach ($s in $sections) { $mergedByKey[$s] = @{} }
$mergedNoKey = @{}
foreach ($s in $sections) { $mergedNoKey[$s] = [System.Collections.Generic.List[string[]]]::new() }

foreach ($acc in $raw.Keys) {
    Write-Host "    ~ $acc" -ForegroundColor DarkGray
    $parsed = Parse-All $raw[$acc] $sections
    foreach ($s in $sections) {
        foreach ($e in $parsed[$s]) {
            $key = $null
            if ($s -eq "WeakAuras") {
                $uid = Get-UID $e
                if ($uid) { $key = "uid:$uid" }
            }
            if ($key -eq $null) {
                $n = Get-Name $e
                if ($n) { $key = "name:$n" }
            }

            if ($key -eq $null) {
                # No stable key: always keep (no dedup possible)
                $mergedNoKey[$s].Add($e)
            } else {
                $savedAt = Get-SavedAt $e
                if (-not $mergedByKey[$s].ContainsKey($key)) {
                    $mergedByKey[$s][$key] = [PSCustomObject]@{ Entry = $e; SavedAt = $savedAt }
                } elseif ($savedAt -gt $mergedByKey[$s][$key].SavedAt) {
                    $mergedByKey[$s][$key] = [PSCustomObject]@{ Entry = $e; SavedAt = $savedAt }
                }
            }
        }
    }
}

# Build final merged lists
$merged = @{}
foreach ($s in $sections) {
    $merged[$s] = [System.Collections.Generic.List[string[]]]::new()
    foreach ($kv in $mergedByKey[$s].Values) { $merged[$s].Add($kv.Entry) }
    foreach ($e in $mergedNoKey[$s])          { $merged[$s].Add($e) }
}

# Apply tombstones: collect deletion timestamps from ALL accounts (max wins),
# then drop entries whose savedAt <= tombstone timestamp.
# If the entry was re-saved AFTER deletion (savedAt > tombstoneAt) it survives.
foreach ($s in $sections) {
    $ts = @{}
    foreach ($acc in $raw.Keys) {
        foreach ($kv in (Get-Tombstones $raw[$acc] $s).GetEnumerator()) {
            if (-not $ts.ContainsKey($kv.Key) -or $kv.Value -gt $ts[$kv.Key]) {
                $ts[$kv.Key] = $kv.Value
            }
        }
    }
    if ($ts.Count -eq 0) { continue }
    $filtered = [System.Collections.Generic.List[string[]]]::new()
    foreach ($e in $merged[$s]) {
        $n = Get-Name $e
        if ($n -and $ts.ContainsKey($n) -and (Get-SavedAt $e) -le $ts[$n]) {
            continue  # deleted and not re-saved since
        }
        $filtered.Add($e)
    }
    $removed = $merged[$s].Count - $filtered.Count
    if ($removed -gt 0) {
        Write-Host ("  " + $s + ": removed $removed deleted") -ForegroundColor DarkYellow
        $merged[$s] = $filtered
    }
}

# Print summary
foreach ($s in $sections) {
    if ($merged[$s].Count -gt 0) {
        Write-Host ("  " + $s + ": " + $merged[$s].Count + " entries") -ForegroundColor Gray
    }
}

Write-Host "  Building output..." -ForegroundColor Gray
$result = Rebuild-Base $base $merged $sections

Write-Host ""
$ok = 0
foreach ($acc in $accounts) {
    try {
        $path = "WTF\Account\$acc\SavedVariables\AuraHub.lua"
        Copy-Item $path ($path + ".bak") -Force
        [System.IO.File]::WriteAllText($path, $result, $enc)
        Write-Host "    OK  $acc" -ForegroundColor Green
        $ok++
    } catch {
        Write-Host "    FAIL  $acc  --  $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "  Done! $ok account(s) updated." -ForegroundColor Green
Write-Host "  Log in to any account -- all data is now synced." -ForegroundColor Cyan
Write-Host "  Backups saved as .bak in each account folder." -ForegroundColor DarkGray
Write-Host ""
Read-Host "  Press Enter to close"
