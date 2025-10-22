#!/bin/bash
# Promnesia Source Watcher
# Auto-rebuilds extension when source files change

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Watching src/ for changes...${NC}"
echo -e "${YELLOW}Auto-rebuild enabled (Ctrl+C to stop)${NC}"
echo ""

# Function to rebuild
rebuild() {
    echo -e "${YELLOW}[$(date +%H:%M:%S)] Source changed, rebuilding...${NC}"
    TARGET=firefox MANIFEST=v2 EXT_ID=promnesia@dev npm run build 2>&1 | \
        grep -v "^$" | \
        sed "s/^/  /"
    echo -e "${GREEN}[$(date +%H:%M:%S)] Build complete! Extension will auto-reload.${NC}"
    echo ""
}

# Don't do initial build here - dev.sh handles it
# This script only watches for subsequent changes

# Watch src/ directory for changes using fswatch (or fall back to find+sleep)
if command -v fswatch &> /dev/null; then
    # Use fswatch if available (brew install fswatch)
    fswatch -o src/ | while read; do
        rebuild
    done
else
    # Fallback: manual polling
    echo -e "${YELLOW}Note: Install fswatch for faster change detection: brew install fswatch${NC}"
    echo ""

    LAST_CHANGE=$(find src -type f -newer dist/firefox 2>/dev/null | wc -l)

    while true; do
        sleep 2
        CHANGES=$(find src -type f -newer dist/firefox 2>/dev/null | wc -l)
        if [ "$CHANGES" -gt 0 ]; then
            rebuild
        fi
    done
fi
