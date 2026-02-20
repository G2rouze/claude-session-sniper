# claude-session-sniper

Automatically fires a Claude Code session at **06:00, 11:00, and 16:00 CET, Monday–Friday**, so a fresh session is always ready at the start of each work block.

Scheduling is handled by a self-hosted **n8n** instance. The workflow runs `claude -p "Hello"` via the Execute Command node, which starts and cleanly exits a non-interactive Claude Code session.

---

## Repository layout

```
claude-session-sniper/
├── README.md
├── .gitignore
├── workflows/
│   └── claude-session-sniper.json   # n8n workflow (importable)
└── scripts/
    └── setup.sh                     # Server setup script
```

---

## Quick start

### 1. Install Claude Code on the server

SSH in as the **same OS user that runs n8n**, then:

```bash
git clone https://github.com/YOU/claude-session-sniper.git
cd claude-session-sniper
bash scripts/setup.sh
```

If the script prints a PATH warning, add the suggested `export PATH=…` line to your `~/.bashrc` (or equivalent) and re-login.

### 2. Authenticate (one-time, interactive)

```bash
claude auth login   # follow the browser URL that appears
claude -p "Hello"   # verify: should print a Claude response and exit 0
```

Credentials are saved to `~/.claude/` and reused automatically by the workflow.

### 3. Import the n8n workflow

1. n8n UI → **Workflows** → **Import from File**
2. Select `workflows/claude-session-sniper.json`
3. Open the **Execute Command** node and replace the `claude` path if needed
   (run `which claude` on the server to get the absolute path)
4. **Activate** the workflow

### 4. Verify

- Click **Execute Workflow** manually in n8n
- Confirm the **Log Success** branch fires and stdout shows a Claude response
- Check n8n execution history the next morning at 06:00 CET

---

## How it works

```
Schedule Trigger (6:00 / 11:00 / 16:00, Mon–Fri, Europe/Paris)
        │
        ▼
Execute Command: claude -p "Hello"
        │
        ▼
    IF exitCode == 0
       │              │
       ▼              ▼
 Log Success      Log Error
```

The `-p` flag runs Claude Code non-interactively: it sends the prompt, receives the response, and exits cleanly.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Workflow hits **Log Error** | Re-run `claude auth login` on the server — the OAuth token may have expired |
| `claude: command not found` in n8n | Use the absolute path (e.g. `/home/user/.npm-global/bin/claude`) in the Execute Command node |
| Wrong user auth | Make sure `claude auth login` was run as the same OS user that runs n8n |

### Optional notifications

Replace either **Log Success** or **Log Error** (or both) with an **HTTP Request** node pointing at a Discord, Telegram, or Gotify webhook to get pinged on failures.

---

## Auth token note

The OAuth token lives in `~/.claude/`. If the n8n service user and the user who ran `claude auth login` differ, auth will silently fail. Always authenticate as the n8n service user.
