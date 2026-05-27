# CodeX-Ray Installer — Windows PowerShell
# Usage: irm https://raw.githubusercontent.com/blackmoon87/CodeX-Ray/main/install.ps1 | iex

$INSTALL_DIR = "$env:USERPROFILE\.codex-ray"
$PLUGIN_DIR  = "$INSTALL_DIR\codex-ray-plugin"
$REPO_URL    = "https://github.com/blackmoon87/CodeX-Ray.git"

$env:COREPACK_ENABLE_STRICT = "0"
$env:COREPACK_ENABLE_AUTO_PIN = "0"

function Write-Step($num, $total, $msg) {
    Write-Host "`n[$num/$total] " -ForegroundColor Yellow -NoNewline
    Write-Host $msg
}

function Write-OK($msg) {
    Write-Host "  [OK] " -ForegroundColor Green -NoNewline
    Write-Host $msg
}

function Write-Err($msg) {
    Write-Host "  [X] " -ForegroundColor Red -NoNewline
    Write-Host $msg
}

function Run-Pnpm {
    param([string]$Args)
    cmd /c "set COREPACK_ENABLE_STRICT=0 && pnpm $Args 2>nul"
}

Write-Host ""
Write-Host "  ======================================" -ForegroundColor Cyan
Write-Host "       CodeX-Ray Installer" -ForegroundColor Cyan
Write-Host "       AI Codebase Analysis Tool" -ForegroundColor Cyan
Write-Host "  ======================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Check prerequisites ---
Write-Step 1 4 "Checking prerequisites..."

$nodeVer = $null
try { $nodeVer = (node --version 2>$null) } catch {}
if (-not $nodeVer) { Write-Err "Node.js not found. Install from https://nodejs.org"; return }
$nodeMajor = [int]($nodeVer -replace 'v(\d+)\..*', '$1')
if ($nodeMajor -lt 22) { Write-Err "Node.js $nodeVer found, but 22+ required"; return }
Write-OK "Node.js $nodeVer"

$pnpmVer = $null
try { $pnpmVer = (cmd /c "pnpm --version 2>nul") } catch {}
if (-not $pnpmVer) {
    Write-Host "  --> Installing pnpm..." -ForegroundColor Yellow
    npm install -g pnpm 2>$null
    $pnpmVer = "installed"
}
Write-OK "pnpm $pnpmVer"

$pyVer = $null
try { $pyVer = (python --version 2>$null) } catch {}
if (-not $pyVer) { Write-Err "Python not found. Install from https://python.org"; return }
Write-OK "$pyVer"

$gitVer = $null
try { $gitVer = (git --version 2>$null) } catch {}
if (-not $gitVer) { Write-Err "Git not found. Install from https://git-scm.com"; return }
Write-OK "$gitVer"

# --- Step 2: Clone or update ---
Write-Step 2 4 "Installing to $INSTALL_DIR..."

if (Test-Path "$INSTALL_DIR\.git") {
    Write-Host "  --> Updating existing installation..." -ForegroundColor Yellow
    Push-Location $INSTALL_DIR
    git pull --ff-only 2>$null
    Pop-Location
} else {
    if (Test-Path $INSTALL_DIR) {
        Remove-Item $INSTALL_DIR -Recurse -Force -ErrorAction SilentlyContinue
    }
    git clone $REPO_URL $INSTALL_DIR 2>$null
}
Write-OK "Repository ready"

# --- Step 3: Install dependencies ---
Write-Step 3 4 "Installing dependencies..."
Push-Location $PLUGIN_DIR
Run-Pnpm "install"
Pop-Location
Write-OK "Dependencies installed"

# --- Step 4: Build core engine ---
Write-Step 4 4 "Building core engine..."
Push-Location $PLUGIN_DIR
Run-Pnpm "--filter @codex-ray/core build"
Pop-Location
Write-OK "Core engine built"

# --- Done ---
Write-Host ""
Write-Host "  ======================================" -ForegroundColor Green
Write-Host "       CodeX-Ray installed!" -ForegroundColor Green
Write-Host "  ======================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Location:  " -ForegroundColor Cyan -NoNewline
Write-Host $INSTALL_DIR
Write-Host "  Usage:     " -ForegroundColor Cyan -NoNewline
Write-Host 'Ask your AI editor: "Analyze the project at c:\path\to\project"' -ForegroundColor Green
Write-Host ""
