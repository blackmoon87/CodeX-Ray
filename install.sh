#!/usr/bin/env bash
# CodeX-Ray Installer — Linux/macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/blackmoon87/CodeX-Ray/main/install.sh | bash

set -e

INSTALL_DIR="$HOME/.codex-ray"
PLUGIN_DIR="$INSTALL_DIR/codex-ray-plugin"
REPO_URL="https://github.com/blackmoon87/CodeX-Ray.git"
SKILL_GUIDE="$INSTALL_DIR/SKILL_GUIDE.md"

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; N='\033[0m'

echo ""
echo -e "${C}  ======================================${N}"
echo -e "${C}       CodeX-Ray Installer${N}"
echo -e "${C}       AI Codebase Analysis Tool${N}"
echo -e "${C}  ======================================${N}"
echo ""

# --- Step 1 ---
echo -e "${Y}[1/5]${N} Checking prerequisites..."

command -v node &>/dev/null || { echo -e "  ${R}[X]${N} Node.js not found. Install from https://nodejs.org"; exit 1; }
NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
[ "$NODE_VER" -lt 22 ] && { echo -e "  ${R}[X]${N} Node.js $NODE_VER found, 22+ required"; exit 1; }
echo -e "  ${G}[OK]${N} Node.js $(node -v)"

if ! command -v pnpm &>/dev/null; then
    echo -e "  ${Y}-->${N} Installing pnpm..."
    npm install -g pnpm 2>/dev/null
fi
echo -e "  ${G}[OK]${N} pnpm $(pnpm --version)"

command -v python3 &>/dev/null || command -v python &>/dev/null || { echo -e "  ${R}[X]${N} Python not found"; exit 1; }
echo -e "  ${G}[OK]${N} $(python3 --version 2>/dev/null || python --version)"

command -v git &>/dev/null || { echo -e "  ${R}[X]${N} Git not found"; exit 1; }
echo -e "  ${G}[OK]${N} $(git --version)"

# --- Step 2 ---
echo -e "\n${Y}[2/5]${N} Installing to ${C}$INSTALL_DIR${N}..."

if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "  ${Y}-->${N} Updating existing installation..."
    cd "$INSTALL_DIR" && git pull --ff-only 2>/dev/null
else
    [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
    git clone "$REPO_URL" "$INSTALL_DIR" 2>/dev/null
fi
echo -e "  ${G}[OK]${N} Repository ready"

# --- Step 3 ---
echo -e "\n${Y}[3/5]${N} Installing dependencies..."
cd "$PLUGIN_DIR"
COREPACK_ENABLE_STRICT=0 pnpm install 2>/dev/null
echo -e "  ${G}[OK]${N} Dependencies installed"

# --- Step 4 ---
echo -e "\n${Y}[4/5]${N} Building core engine..."
COREPACK_ENABLE_STRICT=0 pnpm --filter @codex-ray/core build 2>/dev/null
echo -e "  ${G}[OK]${N} Core engine built"

# --- Step 5: Register with AI editors ---
echo -e "\n${Y}[5/5]${N} Registering with AI editors..."
REGISTERED=0

# Antigravity
if [ -d "$HOME/.gemini/antigravity" ]; then
    KI_DIR="$HOME/.gemini/antigravity/knowledge/codex-ray-tool"
    mkdir -p "$KI_DIR/artifacts"
    cat > "$KI_DIR/metadata.json" <<EOFJ
{
  "title": "CodeX-Ray Tool Integration",
  "summary": "CodeX-Ray codebase analysis tool installed at ~/.codex-ray. When the user asks to analyze/understand any project, read the skill guide at artifacts/skill-guide.md and run the full 7-phase pipeline. GitHub: https://github.com/blackmoon87/CodeX-Ray",
  "createdAt": "$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)",
  "updatedAt": "$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)",
  "references": []
}
EOFJ
    cp "$SKILL_GUIDE" "$KI_DIR/artifacts/skill-guide.md"
    echo -e "  ${G}[OK]${N} Antigravity (Gemini)"
    REGISTERED=$((REGISTERED+1))
fi

# Cursor
if [ -d "$HOME/.cursor" ]; then
    mkdir -p "$HOME/.cursor/rules"
    cat > "$HOME/.cursor/rules/codex-ray.mdc" <<EOFC
---
description: CodeX-Ray codebase analysis tool
globs:
alwaysApply: true
---

# CodeX-Ray Integration

When the user asks to "analyze", "understand", or "map" a project, use CodeX-Ray.

- **Tool location**: \`~/.codex-ray/codex-ray-plugin\`
- **Full instructions**: Read \`~/.codex-ray/SKILL_GUIDE.md\`

Execute ALL 7 phases. Do NOT skip any phase. Do NOT analyze manually.
EOFC
    echo -e "  ${G}[OK]${N} Cursor"
    REGISTERED=$((REGISTERED+1))
fi

# Claude Code
if [ -d "$HOME/.claude" ]; then
    CLAUDE_MD="$HOME/.claude/CLAUDE.md"
    MARKER="<!-- codex-ray -->"
    if [ -f "$CLAUDE_MD" ]; then
        if ! grep -q "codex-ray" "$CLAUDE_MD" 2>/dev/null; then
            cat >> "$CLAUDE_MD" <<EOFCL

$MARKER
## CodeX-Ray Integration
When asked to analyze/understand a codebase, use CodeX-Ray at \`~/.codex-ray/codex-ray-plugin\`.
Read \`~/.codex-ray/SKILL_GUIDE.md\` for the full 7-phase pipeline. Do NOT analyze manually.
$MARKER
EOFCL
        fi
    else
        cat > "$CLAUDE_MD" <<EOFCL
$MARKER
## CodeX-Ray Integration
When asked to analyze/understand a codebase, use CodeX-Ray at \`~/.codex-ray/codex-ray-plugin\`.
Read \`~/.codex-ray/SKILL_GUIDE.md\` for the full 7-phase pipeline. Do NOT analyze manually.
$MARKER
EOFCL
    fi
    echo -e "  ${G}[OK]${N} Claude Code"
    REGISTERED=$((REGISTERED+1))
fi

# Windsurf
if [ -d "$HOME/.codeium/windsurf" ]; then
    mkdir -p "$HOME/.codeium/windsurf/memories/global"
    cat > "$HOME/.codeium/windsurf/memories/global/codex-ray.md" <<EOFW
CodeX-Ray is installed at ~/.codex-ray/codex-ray-plugin.
When the user asks to analyze or understand a project, read ~/.codex-ray/SKILL_GUIDE.md and execute the full 7-phase pipeline.
Do NOT analyze manually — use the CodeX-Ray scripts.
EOFW
    echo -e "  ${G}[OK]${N} Windsurf"
    REGISTERED=$((REGISTERED+1))
fi

# Cline
if [ -d "$HOME/.cline" ]; then
    cat > "$HOME/.cline/codex-ray-instructions.md" <<EOFCN
# CodeX-Ray Integration
When asked to analyze/understand a codebase, use CodeX-Ray at ~/.codex-ray/codex-ray-plugin.
Read ~/.codex-ray/SKILL_GUIDE.md for the full 7-phase pipeline.
EOFCN
    echo -e "  ${G}[OK]${N} Cline"
    REGISTERED=$((REGISTERED+1))
fi

[ $REGISTERED -eq 0 ] && echo -e "  ${Y}[!]${N} No AI editors detected. Read: $SKILL_GUIDE"

# --- Done ---
echo ""
echo -e "${G}  ======================================${N}"
echo -e "${G}       CodeX-Ray installed!${N}"
echo -e "${G}  ======================================${N}"
echo ""
echo -e "  ${C}Location:${N}  $INSTALL_DIR"
echo -e "  ${C}Editors:${N}   $REGISTERED AI editor(s) registered"
echo -e "  ${C}Usage:${N}     Ask your AI editor: \"Analyze the project at /path/to/project\""
echo ""
