#!/bin/bash
# Promnesia Development Watcher (for use with main Firefox profile)
# This only watches and rebuilds - you load the extension manually in Firefox

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔧 Promnesia Development Watcher${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}This script watches src/ and rebuilds automatically.${NC}"
echo -e "${BLUE}Use with your MAIN Firefox profile!${NC}"
echo ""
echo -e "${GREEN}📋 Setup Instructions:${NC}"
echo -e "  1. Open your regular Firefox"
echo -e "  2. Go to: ${YELLOW}about:debugging#/runtime/this-firefox${NC}"
echo -e "  3. Click: ${YELLOW}Load Temporary Add-on...${NC}"
echo -e "  4. Navigate to: ${YELLOW}$SCRIPT_DIR/dist/firefox/${NC}"
echo -e "  5. Select: ${YELLOW}manifest.json${NC}"
echo ""
echo -e "${GREEN}💡 When you make changes:${NC}"
echo -e "  - This script auto-rebuilds (~2 seconds)"
echo -e "  - In about:debugging, click ${YELLOW}Reload${NC} next to Promnesia"
echo -e "  - Changes appear instantly!"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Initial build
echo -e "${GREEN}Building extension...${NC}"
TARGET=firefox MANIFEST=v2 EXT_ID=promnesia@dev npm run build
echo -e "${GREEN}✓ Initial build complete!${NC}"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo -e "${CYAN}Watcher stopped.${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Function to rebuild
rebuild() {
    echo -e "${YELLOW}[$(date +%H:%M:%S)] Source changed, rebuilding...${NC}"
    TARGET=firefox MANIFEST=v2 EXT_ID=promnesia@dev npm run build 2>&1 | \
        grep -E "(created|error)" | \
        sed "s/^/  /"
    echo -e "${GREEN}[$(date +%H:%M:%S)] ✓ Build complete! Reload extension in Firefox.${NC}"
    echo ""
}

echo -e "${GREEN}👀 Watching src/ for changes... (Ctrl+C to stop)${NC}"
echo ""

# Watch src/ directory for changes using fswatch (or fall back to polling)
if command -v fswatch &> /dev/null; then
    # Use fswatch if available
    fswatch -o src/ | while read; do
        rebuild
    done
else
    # Fallback: manual polling
    echo -e "${YELLOW}💡 Install fswatch for instant change detection: brew install fswatch${NC}"
    echo ""

    while true; do
        sleep 2
        CHANGES=$(find src -type f -newer dist/firefox -print 2>/dev/null | wc -l | tr -d ' ')
        if [ "$CHANGES" -gt "0" ]; then
            rebuild
        fi
    done
fi
