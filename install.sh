#!/usr/bin/env bash
# CodeX-Ray Installer — Linux/macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/blackmoon87/CodeX-Ray/main/install.sh | bash

set -e

INSTALL_DIR="$HOME/.codex-ray"
PLUGIN_DIR="$INSTALL_DIR/codex-ray-plugin"
REPO_URL="https://github.com/blackmoon87/CodeX-Ray.git"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     🔬 CodeX-Ray Installer           ║${NC}"
echo -e "${CYAN}║     AI Codebase Analysis Tool         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# --- Step 1: Check prerequisites ---
echo -e "${YELLOW}[1/5]${NC} Checking prerequisites..."

if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js not found. Install Node.js 22+ from https://nodejs.org${NC}"
    exit 1
fi

NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VER" -lt 22 ]; then
    echo -e "${RED}✗ Node.js $NODE_VER found, but 22+ required${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Node.js $(node -v)"

if ! command -v pnpm &> /dev/null; then
    echo -e "  ${YELLOW}→ Installing pnpm...${NC}"
    npm install -g pnpm
fi
echo -e "  ${GREEN}✓${NC} pnpm $(pnpm --version)"

if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}✗ Python not found. Install Python 3.10+ from https://python.org${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Python $(python3 --version 2>/dev/null || python --version)"

if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git not found. Install Git from https://git-scm.com${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Git $(git --version | cut -d' ' -f3)"

# --- Step 2: Clone or update ---
echo ""
echo -e "${YELLOW}[2/5]${NC} Installing to ${CYAN}$INSTALL_DIR${NC}..."

if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "  ${YELLOW}→ Existing installation found. Updating...${NC}"
    cd "$INSTALL_DIR"
    git pull --ff-only
else
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "  ${YELLOW}→ Removing incomplete installation...${NC}"
        rm -rf "$INSTALL_DIR"
    fi
    git clone "$REPO_URL" "$INSTALL_DIR"
fi
echo -e "  ${GREEN}✓${NC} Repository ready"

# --- Step 3: Install dependencies ---
echo ""
echo -e "${YELLOW}[3/5]${NC} Installing dependencies..."
cd "$PLUGIN_DIR"
pnpm install --no-frozen-lockfile 2>&1 | tail -5

# --- Step 4: Approve & build Tree-sitter ---
echo ""
echo -e "${YELLOW}[4/5]${NC} Building Tree-sitter parsers..."

# Auto-approve all builds by adding to pnpm config
cat > "$PLUGIN_DIR/.pnpmfile.cjs" 2>/dev/null << 'EOF'
module.exports = { hooks: { readPackage(pkg) { return pkg; } } };
EOF

# Try approve-builds with auto-yes, fallback to manual
if echo "a
y" | pnpm approve-builds 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Tree-sitter parsers built"
else
    echo -e "  ${YELLOW}→ Run 'cd $PLUGIN_DIR && pnpm approve-builds' manually${NC}"
fi

# --- Step 5: Build core engine ---
echo ""
echo -e "${YELLOW}[5/5]${NC} Building CodeX-Ray core engine..."
pnpm --filter @codex-ray/core build
echo -e "  ${GREEN}✓${NC} Core engine built"

# --- Done ---
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ CodeX-Ray installed!           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Location:${NC} $INSTALL_DIR"
echo -e "  ${CYAN}Usage:${NC}    Ask your AI editor:"
echo -e "           ${GREEN}\"Analyze the project at /path/to/project\"${NC}"
echo -e "           ${GREEN}\"حلل المشروع /path/to/project\"${NC}"
echo ""
