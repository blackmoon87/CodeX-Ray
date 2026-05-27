#!/usr/bin/env bash
# CodeX-Ray Installer — Linux/macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/blackmoon87/CodeX-Ray/main/install.sh | bash

set -e

INSTALL_DIR="$HOME/.codex-ray"
PLUGIN_DIR="$INSTALL_DIR/codex-ray-plugin"
REPO_URL="https://github.com/blackmoon87/CodeX-Ray.git"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}  ======================================${NC}"
echo -e "${CYAN}       CodeX-Ray Installer${NC}"
echo -e "${CYAN}       AI Codebase Analysis Tool${NC}"
echo -e "${CYAN}  ======================================${NC}"
echo ""

# --- Step 1: Check prerequisites ---
echo -e "${YELLOW}[1/4]${NC} Checking prerequisites..."

if ! command -v node &> /dev/null; then
    echo -e "  ${RED}[X]${NC} Node.js not found. Install from https://nodejs.org"
    exit 1
fi
NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VER" -lt 22 ]; then
    echo -e "  ${RED}[X]${NC} Node.js v$NODE_VER found, but 22+ required"
    exit 1
fi
echo -e "  ${GREEN}[OK]${NC} Node.js $(node -v)"

if ! command -v pnpm &> /dev/null; then
    echo -e "  ${YELLOW}-->${NC} Installing pnpm..."
    npm install -g pnpm
fi
echo -e "  ${GREEN}[OK]${NC} pnpm $(pnpm --version)"

if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "  ${RED}[X]${NC} Python not found. Install from https://python.org"
    exit 1
fi
echo -e "  ${GREEN}[OK]${NC} $(python3 --version 2>/dev/null || python --version)"

if ! command -v git &> /dev/null; then
    echo -e "  ${RED}[X]${NC} Git not found. Install from https://git-scm.com"
    exit 1
fi
echo -e "  ${GREEN}[OK]${NC} $(git --version)"

# --- Step 2: Clone or update ---
echo ""
echo -e "${YELLOW}[2/4]${NC} Installing to ${CYAN}$INSTALL_DIR${NC}..."

if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "  ${YELLOW}-->${NC} Existing installation found. Updating..."
    cd "$INSTALL_DIR"
    git pull --ff-only
else
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "  ${YELLOW}-->${NC} Removing incomplete installation..."
        rm -rf "$INSTALL_DIR"
    fi
    git clone "$REPO_URL" "$INSTALL_DIR"
fi
echo -e "  ${GREEN}[OK]${NC} Repository ready"

# --- Step 3: Install dependencies + Tree-sitter ---
echo ""
echo -e "${YELLOW}[3/4]${NC} Installing dependencies and Tree-sitter parsers..."
cd "$PLUGIN_DIR"
pnpm install
echo -e "  ${GREEN}[OK]${NC} Dependencies installed"

# --- Step 4: Build core engine ---
echo ""
echo -e "${YELLOW}[4/4]${NC} Building CodeX-Ray core engine..."
pnpm --filter @codex-ray/core build
echo -e "  ${GREEN}[OK]${NC} Core engine built"

# --- Done ---
echo ""
echo -e "${GREEN}  ======================================${NC}"
echo -e "${GREEN}       CodeX-Ray installed!${NC}"
echo -e "${GREEN}  ======================================${NC}"
echo ""
echo -e "  ${CYAN}Location:${NC} $INSTALL_DIR"
echo -e "  ${CYAN}Usage:${NC}    Ask your AI editor:"
echo -e "           ${GREEN}\"Analyze the project at /path/to/project\"${NC}"
echo -e "           ${GREEN}\"حلل المشروع /path/to/project\"${NC}"
echo ""
