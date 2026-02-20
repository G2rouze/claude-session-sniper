#!/usr/bin/env bash
# setup.sh — Install Claude Code for the claude-session-sniper workflow
# Run as the same OS user that runs n8n (NOT root).

set -euo pipefail

# ── 1. Refuse root ────────────────────────────────────────────────────────────
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "ERROR: Do not run this script as root."
  echo "       Claude Code auth is per-user. Run as the same user that runs n8n."
  exit 1
fi

echo "Running as user: $(whoami)"
echo

# ── 2. Check Node.js ≥ 18 ────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  echo "ERROR: Node.js is not installed or not on PATH."
  echo "       Install Node.js 18+ (https://nodejs.org/) and re-run this script."
  exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)

if [[ "$NODE_MAJOR" -lt 18 ]]; then
  echo "ERROR: Node.js 18+ required. Found: v${NODE_VERSION}"
  echo "       Upgrade Node.js and re-run this script."
  exit 1
fi

echo "Node.js version: v${NODE_VERSION} — OK"
echo

# ── 3. Install Claude Code ────────────────────────────────────────────────────
echo "Installing @anthropic-ai/claude-code globally..."
npm install -g @anthropic-ai/claude-code
echo

# ── 4. PATH check ────────────────────────────────────────────────────────────
CLAUDE_BIN=$(command -v claude 2>/dev/null || true)

if [[ -z "$CLAUDE_BIN" ]]; then
  NPM_BIN=$(npm bin -g 2>/dev/null || npm root -g 2>/dev/null | sed 's|/lib/node_modules||')/../bin)
  echo "WARNING: 'claude' is not on your PATH."
  echo
  echo "  Add this to your ~/.bashrc (or ~/.zshrc, ~/.profile):"
  echo "    export PATH=\"${NPM_BIN}:\$PATH\""
  echo
  echo "  Then reload your shell:"
  echo "    source ~/.bashrc"
  echo
  echo "  After that, get the absolute path for n8n's Execute Command node:"
  echo "    which claude"
  echo
else
  echo "Claude Code binary: ${CLAUDE_BIN} — OK"
  echo
  echo "Absolute path for n8n's Execute Command node:"
  echo "  ${CLAUDE_BIN} -p \"Hello\""
  echo
fi

# ── 5. Auth instructions ──────────────────────────────────────────────────────
cat <<'INSTRUCTIONS'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 NEXT STEP — Authenticate Claude Code (one-time, requires browser)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. Run:
       claude auth login

  2. A URL will be printed. Open it in a browser and sign in with your
     Claude.ai Pro account.

  3. Verify it works:
       claude -p "Hello"

     You should see a Claude response and the command should exit 0.

  4. Import the n8n workflow:
       n8n UI → Workflows → Import from File
       → select  workflows/claude-session-sniper.json

  5. In the Execute Command node, replace 'claude' with its absolute path
     (printed above, or run: which claude).

  6. Activate the workflow in n8n.

  Credentials are stored in ~/.claude/ and reused automatically.
  Re-run 'claude auth login' if the n8n workflow starts hitting the error branch.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSTRUCTIONS
