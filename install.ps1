# CodeX-Ray Installer — Windows PowerShell
# Usage: irm https://raw.githubusercontent.com/blackmoon87/CodeX-Ray/main/install.ps1 | iex

$ErrorActionPreference = "Continue"
$env:COREPACK_ENABLE_STRICT = "0"
$env:COREPACK_ENABLE_AUTO_PIN = "0"

$INSTALL_DIR = "$env:USERPROFILE\.codex-ray"
$PLUGIN_DIR  = "$INSTALL_DIR\codex-ray-plugin"
$REPO_URL    = "https://github.com/blackmoon87/CodeX-Ray.git"
$SKILL_GUIDE = "$INSTALL_DIR\SKILL_GUIDE.md"

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

$nodeVer = $null
try { $nodeVer = (cmd /c "node --version 2>nul") } catch {}
if (-not $nodeVer) { Write-Err "Node.js not found. Install from https://nodejs.org"; return }
$nodeMajor = [int]($nodeVer -replace 'v(\d+)\..*', '$1')
if ($nodeMajor -lt 22) { Write-Err "Node.js $nodeVer found, but 22+ required"; return }
Write-OK "Node.js $nodeVer"

$pnpmVer = $null
try { $pnpmVer = (cmd /c "pnpm --version 2>nul") } catch {}
if (-not $pnpmVer) {
    Write-Host "  --> Installing pnpm..." -ForegroundColor Yellow
    cmd /c "npm install -g pnpm 2>nul"
    $pnpmVer = "installed"
}
Write-OK "pnpm $pnpmVer"

$pyVer = $null
try { $pyVer = (cmd /c "python --version 2>nul") } catch {}
if (-not $pyVer) { Write-Err "Python not found. Install from https://python.org"; return }
Write-OK "$pyVer"

$gitVer = $null
try { $gitVer = (cmd /c "git --version 2>nul") } catch {}
if (-not $gitVer) { Write-Err "Git not found. Install from https://git-scm.com"; return }
Write-OK "$gitVer"

# --- Step 2: Clone or update ---
Write-Step 2 5 "Installing to $INSTALL_DIR..."

if (Test-Path "$INSTALL_DIR\.git") {
    Write-Host "  --> Updating existing installation..." -ForegroundColor Yellow
    cmd /c "cd /d `"$INSTALL_DIR`" && git pull --ff-only 2>nul"
} else {
    if (Test-Path $INSTALL_DIR) {
        Remove-Item $INSTALL_DIR -Recurse -Force -ErrorAction SilentlyContinue
    }
    cmd /c "git clone `"$REPO_URL`" `"$INSTALL_DIR`" 2>nul"
}
Write-OK "Repository ready"

# --- Step 3: Install dependencies ---
Write-Step 3 5 "Installing dependencies..."
cmd /c "cd /d `"$PLUGIN_DIR`" && set COREPACK_ENABLE_STRICT=0 && pnpm install 2>nul"
Write-OK "Dependencies installed"

# --- Step 4: Build core engine ---
Write-Step 4 5 "Building core engine..."
cmd /c "cd /d `"$PLUGIN_DIR`" && set COREPACK_ENABLE_STRICT=0 && pnpm --filter @codex-ray/core build 2>nul"
Write-OK "Core engine built"

# --- Step 5: Register with AI editors ---
Write-Step 5 5 "Registering with AI editors..."

$registered = 0

# --- Antigravity ---
$antigravityDir = "$env:USERPROFILE\.gemini\antigravity\knowledge"
if (Test-Path "$env:USERPROFILE\.gemini\antigravity") {
    $kiDir = "$antigravityDir\codex-ray-tool"
    New-Item -ItemType Directory -Force -Path "$kiDir\artifacts" | Out-Null
    @"
{
  "title": "CodeX-Ray Tool Integration",
  "summary": "CodeX-Ray codebase analysis tool installed at ~/.codex-ray. When the user asks to analyze/understand any project, read the skill guide at artifacts/skill-guide.md and run the full 7-phase pipeline. GitHub: https://github.com/blackmoon87/CodeX-Ray",
  "createdAt": "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')",
  "updatedAt": "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')",
  "references": []
}
"@ | Set-Content "$kiDir\metadata.json" -Encoding UTF8
    Copy-Item $SKILL_GUIDE "$kiDir\artifacts\skill-guide.md" -Force
    Write-OK "Antigravity (Gemini)"
    $registered++
}

# --- Cursor ---
$cursorRulesDir = "$env:USERPROFILE\.cursor\rules"
if (Test-Path "$env:USERPROFILE\.cursor") {
    New-Item -ItemType Directory -Force -Path $cursorRulesDir | Out-Null
    @"
---
description: CodeX-Ray codebase analysis tool
globs:
alwaysApply: true
---

# CodeX-Ray Integration

When the user asks to "analyze", "understand", or "map" a project/codebase, use the CodeX-Ray tool.

- **Tool location**: ``$($INSTALL_DIR.Replace('\','/'))/codex-ray-plugin``
- **Full instructions**: Read ``$($INSTALL_DIR.Replace('\','/'))/SKILL_GUIDE.md``

Execute ALL 7 phases of the pipeline. Do NOT skip any phase.
Do NOT analyze manually — use the CodeX-Ray scripts (scan-project.mjs, extract-structure.mjs, etc.)
"@ | Set-Content "$cursorRulesDir\codex-ray.mdc" -Encoding UTF8
    Write-OK "Cursor"
    $registered++
}

# --- Claude Code ---
$claudeDir = "$env:USERPROFILE\.claude"
if (Test-Path $claudeDir) {
    $claudeMd = "$claudeDir\CLAUDE.md"
    $marker = "<!-- codex-ray -->"
    $block = @"

$marker
## CodeX-Ray Integration
When asked to analyze/understand a codebase, use CodeX-Ray at ``~/.codex-ray/codex-ray-plugin``.
Read ``~/.codex-ray/SKILL_GUIDE.md`` for the full 7-phase pipeline instructions.
Do NOT analyze manually — use the CodeX-Ray scripts.
$marker
"@
    if (Test-Path $claudeMd) {
        $content = Get-Content $claudeMd -Raw -Encoding UTF8
        if ($content -notmatch "codex-ray") {
            Add-Content $claudeMd $block -Encoding UTF8
        }
    } else {
        Set-Content $claudeMd $block -Encoding UTF8
    }
    Write-OK "Claude Code"
    $registered++
}

# --- Windsurf (Codeium) ---
$windsurfDir = "$env:USERPROFILE\.codeium\windsurf"
if (Test-Path $windsurfDir) {
    $memoriesDir = "$windsurfDir\memories\global"
    New-Item -ItemType Directory -Force -Path $memoriesDir | Out-Null
    @"
CodeX-Ray is installed at ~/.codex-ray/codex-ray-plugin.
When the user asks to analyze or understand a project, read ~/.codex-ray/SKILL_GUIDE.md and execute the full 7-phase analysis pipeline using CodeX-Ray scripts.
Do NOT analyze manually — use scan-project.mjs, extract-structure.mjs, compute-batches.mjs, and merge-batch-graphs.py.
"@ | Set-Content "$memoriesDir\codex-ray.md" -Encoding UTF8
    Write-OK "Windsurf"
    $registered++
}

# --- Cline ---
$clineDir = "$env:USERPROFILE\.cline"
if (Test-Path $clineDir) {
    @"
# CodeX-Ray Integration
When asked to analyze/understand a codebase, use CodeX-Ray at ~/.codex-ray/codex-ray-plugin.
Read ~/.codex-ray/SKILL_GUIDE.md for the full 7-phase pipeline.
"@ | Set-Content "$clineDir\codex-ray-instructions.md" -Encoding UTF8
    Write-OK "Cline"
    $registered++
}

if ($registered -eq 0) {
    Write-Host "  [!] " -ForegroundColor Yellow -NoNewline
    Write-Host "No AI editors detected. Manual setup: read $INSTALL_DIR\SKILL_GUIDE.md"
}

# --- Done ---
Write-Host ""
Write-Host "  ======================================" -ForegroundColor Green
Write-Host "       CodeX-Ray installed!" -ForegroundColor Green
Write-Host "  ======================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Location:  " -ForegroundColor Cyan -NoNewline
Write-Host $INSTALL_DIR
Write-Host "  Editors:   " -ForegroundColor Cyan -NoNewline
Write-Host "$registered AI editor(s) registered"
Write-Host "  Usage:     " -ForegroundColor Cyan -NoNewline
Write-Host 'Ask your AI editor: "Analyze the project at c:\path\to\project"' -ForegroundColor Green
Write-Host ""
