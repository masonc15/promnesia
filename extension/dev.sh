#!/bin/bash
# Promnesia Development Launcher
# Runs both the file watcher and Firefox with auto-reload

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 Promnesia Development Environment${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}This will:${NC}"
echo -e "  ${GREEN}✓${NC} Launch Firefox with Promnesia extension"
echo -e "  ${GREEN}✓${NC} Auto-reload extension on code changes"
echo -e "  ${GREEN}✓${NC} Persist settings in ~/.promnesia-dev-profile"
echo ""
echo -e "${BLUE}Make a change to any file in src/ and see it instantly!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if promnesia serve is running
if ! pgrep -f "promnesia serve" > /dev/null; then
    echo -e "${RED}⚠️  Warning: promnesia serve is not running!${NC}"
    echo -e "${BLUE}   Start it with: launchctl start com.promnesia.serve${NC}"
    echo ""
fi

# Cleanup function
cleanup() {
    echo ""
    echo -e "${CYAN}Shutting down...${NC}"
    pkill -P $$ 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

# Initial build (synchronous - must complete before Firefox starts)
echo -e "${GREEN}Building extension for first run...${NC}"
TARGET=firefox MANIFEST=v2 EXT_ID=promnesia@dev npm run build

echo -e "${GREEN}Build complete! Starting Firefox and file watcher...${NC}"
echo ""

# Start watcher in background (for subsequent changes)
./dev-watch.sh &
WATCH_PID=$!

# Give watcher a moment to start
sleep 1

# Start Firefox with web-ext (now safe - dist/ exists)
./dev-run.sh &
FIREFOX_PID=$!

# Wait for both processes
wait $WATCH_PID $FIREFOX_PID
