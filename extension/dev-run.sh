#!/bin/bash
# Promnesia Development Runner
# Launches Firefox with auto-reload on source changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Promnesia Development Environment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Build extension if dist doesn't exist or src is newer
if [ ! -d "dist/firefox" ] || [ "src" -nt "dist/firefox" ]; then
    echo -e "${GREEN}Building extension...${NC}"
    TARGET=firefox MANIFEST=v2 EXT_ID=promnesia@dev npm run build
fi

PROFILE_DIR="$HOME/.promnesia-dev-profile"

echo -e "${GREEN}Starting Firefox with Promnesia...${NC}"
echo -e "${BLUE}Profile location: $PROFILE_DIR${NC}"
echo -e "${BLUE}Auto-reload: ENABLED (changes to src/ will auto-reload)${NC}"
echo ""
echo -e "${GREEN}Press Ctrl+C to stop${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Run web-ext with auto-reload
# --keep-profile-changes: Persist settings/config across runs
# --browser-console: Auto-open browser console for debugging
# --start-url: Open backend URL to verify server is running
exec web-ext run \
    --source-dir=dist/firefox \
    --keep-profile-changes \
    --profile-create-if-missing \
    --firefox-profile="$PROFILE_DIR" \
    --start-url="http://localhost:13131" \
    --verbose
