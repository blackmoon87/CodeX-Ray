# CodeX-Ray Installer — Windows PowerShell
# Usage: irm https://raw.githubusercontent.com/blackmoon87/CodeX-Ray/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$INSTALL_DIR = "$env:USERPROFILE\.codex-ray"
$PLUGIN_DIR  = "$INSTALL_DIR\codex-ray-plugin"
$REPO_URL    = "https://github.com/blackmoon87/CodeX-Ray.git"

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

Write-Host ""
Write-Host "  ======================================" -ForegroundColor Cyan
Write-Host "       CodeX-Ray Installer" -ForegroundColor Cyan
Write-Host "       AI Codebase Analysis Tool" -ForegroundColor Cyan
Write-Host "  ======================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Check prerequisites ---
Write-Step 1 5 "Checking prerequisites..."

# Node.js
try {
    $nodeVer = (node --version 2>$null)
    $nodeMajor = [int]($nodeVer -replace 'v(\d+)\..*', '$1')
    if ($nodeMajor -lt 22) {
        Write-Err "Node.js $nodeVer found, but 22+ required"
        Write-Host "    Download: https://nodejs.org" -ForegroundColor Gray
        exit 1
    }
    Write-OK "Node.js $nodeVer"
} catch {
    Write-Err "Node.js not found. Install from https://nodejs.org"
    exit 1
}

# pnpm
try {
    $pnpmVer = (pnpm --version 2>$null)
    Write-OK "pnpm $pnpmVer"
} catch {
    Write-Host "  --> Installing pnpm..." -ForegroundColor Yellow
    npm install -g pnpm
    Write-OK "pnpm installed"
}

# Python
try {
    $pyVer = (python --version 2>$null)
    Write-OK "$pyVer"
} catch {
    Write-Err "Python not found. Install from https://python.org"
    exit 1
}

# Git
try {
    $gitVer = (git --version 2>$null)
    Write-OK "$gitVer"
} catch {
    Write-Err "Git not found. Install from https://git-scm.com"
    exit 1
}

# --- Step 2: Clone or update ---
Write-Step 2 5 "Installing to $INSTALL_DIR..."

if (Test-Path "$INSTALL_DIR\.git") {
    Write-Host "  --> Existing installation found. Updating..." -ForegroundColor Yellow
    Push-Location $INSTALL_DIR
    git pull --ff-only
    Pop-Location
} else {
    if (Test-Path $INSTALL_DIR) {
        Write-Host "  --> Removing incomplete installation..." -ForegroundColor Yellow
        Remove-Item $INSTALL_DIR -Recurse -Force
    }
    git clone $REPO_URL $INSTALL_DIR
}
Write-OK "Repository ready"

# --- Step 3: Install dependencies ---
Write-Step 3 5 "Installing dependencies..."
Push-Location $PLUGIN_DIR
pnpm install --no-frozen-lockfile 2>$null
Pop-Location
Write-OK "Dependencies installed"

# --- Step 4: Approve & build Tree-sitter ---
Write-Step 4 5 "Building Tree-sitter parsers..."
Push-Location $PLUGIN_DIR

# Auto-approve builds
try {
    "a`ny`n" | pnpm approve-builds 2>$null
    Write-OK "Tree-sitter parsers built"
} catch {
    Write-Host "  --> Run manually: cd $PLUGIN_DIR; pnpm approve-builds" -ForegroundColor Yellow
}
Pop-Location

# --- Step 5: Build core engine ---
Write-Step 5 5 "Building CodeX-Ray core engine..."
Push-Location $PLUGIN_DIR
pnpm --filter @codex-ray/core build
Pop-Location
Write-OK "Core engine built"

# --- Done ---
Write-Host ""
Write-Host "  ======================================" -ForegroundColor Green
Write-Host "       CodeX-Ray installed!" -ForegroundColor Green
Write-Host "  ======================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Location: " -ForegroundColor Cyan -NoNewline
Write-Host $INSTALL_DIR
Write-Host "  Usage:    " -ForegroundColor Cyan -NoNewline
Write-Host "Ask your AI editor:"
Write-Host '           "Analyze the project at c:\path\to\project"' -ForegroundColor Green
Write-Host '           "حلل المشروع c:\path\to\project"' -ForegroundColor Green
Write-Host ""
