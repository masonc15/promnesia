# Promnesia Local Development Setup

## 🚀 Quick Start

Simply run:

```bash
cd /Users/colin/repos/promnesia/extension
./dev.sh
```

This will:
- ✅ Build the extension
- ✅ Launch Firefox with Promnesia loaded
- ✅ Auto-reload when you edit any file in `src/`
- ✅ Persist all settings in `~/.promnesia-dev-profile`

**That's it!** The extension is now persistent and will auto-reload on any changes.

---

## 🔧 How It Works

### Three Scripts Working Together:

1. **`dev.sh`** - Main launcher (runs both scripts below)
2. **`dev-watch.sh`** - Watches `src/` and rebuilds when files change
3. **`dev-run.sh`** - Runs Firefox with web-ext auto-reload

### Data Flow:

```
Edit src/showvisited.js
  ↓
dev-watch.sh detects change
  ↓
Rebuilds extension (npm run build)
  ↓
dist/firefox/ is updated
  ↓
web-ext auto-reloads extension in Firefox
  ↓
Changes appear instantly! (< 2 seconds)
```

---

## 📁 Files & Directories

| Path | Purpose |
|------|---------|
| `src/` | Source code (edit here) |
| `dist/firefox/` | Built extension (auto-generated) |
| `~/.promnesia-dev-profile` | Firefox profile (persists settings) |
| `dev.sh` | Main dev launcher |
| `dev-watch.sh` | File watcher + auto-rebuild |
| `dev-run.sh` | Firefox launcher with web-ext |

---

## 🛠️ Development Workflow

### Making Changes:

1. **Start development environment:**
   ```bash
   cd /Users/colin/repos/promnesia/extension
   ./dev.sh
   ```

2. **Edit any source file:**
   ```bash
   # Example: Make tags smaller in popup
   vim src/showvisited.css
   ```

3. **Save the file**
   - Extension rebuilds automatically (watch terminal output)
   - Firefox reloads extension (~2 seconds)
   - Changes appear immediately!

4. **To stop:** Press `Ctrl+C`

### Individual Scripts:

Run separately if needed:

```bash
# Just rebuild once
TARGET=firefox MANIFEST=v2 EXT_ID=promnesia@dev npm run build

# Just watch for changes (no Firefox)
./dev-watch.sh

# Just run Firefox (no watching)
./dev-run.sh
```

---

## 🔍 Debugging

### Check Build Output:

```bash
# In terminal running dev.sh, watch for:
[HH:MM:SS] Source changed, rebuilding...
created dist/firefox in 1.4s
[HH:MM:SS] Build complete! Extension will auto-reload.
```

### Check Firefox Console:

Web-ext automatically opens browser console for debugging:
- Look for: `[promnesia]` messages
- Errors appear here immediately

### Verify Extension Loaded:

1. In Firefox: `about:debugging#/runtime/this-firefox`
2. Look for "Promnesia [dev]"
3. Should show "Internal UUID" and details

---

## 🎯 Testing Changes

### Example: Make Popup Smaller

1. Edit `src/showvisited.css`:
   ```css
   .promnesia-visited-popup {
       font-size: 10px !important;
       max-width: 300px !important;
   }
   ```

2. Save file → auto-rebuild → auto-reload

3. Test:
   - Visit a bookmarked URL
   - Enable "mark visited" (Ctrl+Alt+V)
   - Hover over link → popup should be smaller!

---

## 📦 Extension Persistence

### Profile Location:
`~/.promnesia-dev-profile`

**This profile persists:**
- ✅ Extension settings
- ✅ Backend URL configuration
- ✅ Custom CSS styling
- ✅ Exclude lists
- ✅ Browser bookmarks/history (for testing)

**To reset profile:**
```bash
rm -rf ~/.promnesia-dev-profile
```

---

## 🔄 Backend Integration

The extension expects `promnesia serve` running at `http://localhost:13131`.

**Check if running:**
```bash
launchctl list | grep promnesia
# Should show: com.promnesia.serve
```

**Start if needed:**
```bash
launchctl start com.promnesia.serve
```

**Restart after code changes:**
```bash
launchctl kickstart -k gui/$(id -u)/com.promnesia.serve
```

---

## ⚡ Performance Tips

### Speed up rebuilds:

Install `fswatch` for instant change detection:
```bash
brew install fswatch
```

Without it, the watcher polls every 2 seconds (still fast, but fswatch is instant).

---

## 🐛 Troubleshooting

### "Extension is invalid" error:
- Check `dist/firefox/manifest.json`
- Should have: `"id": "promnesia@dev"`

### Extension doesn't reload:
- Check terminal for rebuild errors
- Try manual rebuild: `npm run build`
- Restart `dev.sh`

### Changes don't appear:
- Clear Firefox cache: Ctrl+Shift+Del
- Hard refresh page: Ctrl+Shift+R
- Check browser console for errors

### Port 13131 connection refused:
- Promnesia server not running
- Start with: `launchctl start com.promnesia.serve`

---

## 📝 Making Changes Permanent

### Option 1: Let auto-indexer handle it (recommended)
Your LaunchAgent indexes at 3 AM daily - changes persist automatically.

### Option 2: Manual re-index
```bash
promnesia index
launchctl kickstart -k gui/$(id -u)/com.promnesia.serve
```

---

## 🎓 Advanced: Build Variants

### Development (current):
```bash
TARGET=firefox MANIFEST=v2 EXT_ID=promnesia@dev npm run build
```

### Production (for distribution):
```bash
./build --firefox --release --lint
```

---

## 💡 Pro Tips

1. **Keep dev.sh running** while coding - instant feedback!

2. **Use browser DevTools** to test CSS changes live, then copy to source

3. **Check terminal output** when things break - build errors show there

4. **Profile is persistent** - your settings survive restarts

5. **Ctrl+C to stop** - cleanly shuts down both watcher and Firefox

---

## 🎉 You're All Set!

Every change you make to `src/` will:
1. Auto-rebuild the extension
2. Auto-reload in Firefox
3. Appear within ~2 seconds

**Happy coding!** 🚀
