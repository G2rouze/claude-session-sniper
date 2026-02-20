# Claude Code — n8n Workflow Assistant

This repo is cloned at `/root/claude-session-sniper/` on the n8n LXC host (192.168.1.100).
Claude Code runs directly on the LXC host as root.

---

## Environment

API key and base URL are in `/root/claude-session-sniper/.env` (never commit this file).

```bash
source /root/claude-session-sniper/.env
# exposes: $N8N_API_KEY, $N8N_BASE_URL (http://localhost:5678)
```

---

## n8n API — common operations

Always set the header: `-H "X-N8N-API-KEY: $N8N_API_KEY"`

### List all workflows
```bash
source .env && curl -s "$N8N_BASE_URL/api/v1/workflows" -H "X-N8N-API-KEY: $N8N_API_KEY" | jq '.data[] | {id, name, active}'
```

### Get a workflow by ID
```bash
source .env && curl -s "$N8N_BASE_URL/api/v1/workflows/<ID>" -H "X-N8N-API-KEY: $N8N_API_KEY" | jq .
```

### Update a workflow (replace nodes/connections)
```bash
source .env && curl -s -X PUT "$N8N_BASE_URL/api/v1/workflows/<ID>" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d @workflows/<file>.json
```

### Activate / deactivate a workflow
```bash
source .env
curl -s -X POST "$N8N_BASE_URL/api/v1/workflows/<ID>/activate" -H "X-N8N-API-KEY: $N8N_API_KEY"
curl -s -X POST "$N8N_BASE_URL/api/v1/workflows/<ID>/deactivate" -H "X-N8N-API-KEY: $N8N_API_KEY"
```

### Trigger a manual execution
```bash
source .env && curl -s -X POST "$N8N_BASE_URL/api/v1/workflows/<ID>/run" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | jq .
```

### Get execution logs (last 10)
```bash
source .env && curl -s "$N8N_BASE_URL/api/v1/executions?workflowId=<ID>&limit=10" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" | jq '.data[] | {id, status, startedAt, stoppedAt}'
```

### Get execution detail (full node output)
```bash
source .env && curl -s "$N8N_BASE_URL/api/v1/executions/<EXEC_ID>" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" | jq .
```

### Create a new workflow
```bash
source .env && curl -s -X POST "$N8N_BASE_URL/api/v1/workflows" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d @workflows/<file>.json | jq '{id, name}'
```

### Delete a workflow
```bash
source .env && curl -s -X DELETE "$N8N_BASE_URL/api/v1/workflows/<ID>" \
  -H "X-N8N-API-KEY: $N8N_API_KEY"
```

---

## Workflow files

All workflow JSON files live in `workflows/`. When editing a workflow:
1. Pull the live version from the API into the file
2. Edit the JSON
3. Push it back via PUT
4. Trigger a test run and check execution logs

---

## Working directory on the LXC

```
/root/claude-session-sniper/
├── CLAUDE.md           ← this file
├── .env                ← API key (not in git)
├── workflows/          ← workflow JSON files
└── scripts/
```

---

## Key facts

- n8n runs in Docker container named `n8n`
- n8n internal URL from the LXC host: `http://localhost:5678`
- n8n external URL: `https://nhuitn.gauthier.ovh`
- Claude Code binary on LXC host: `/usr/local/bin/claude`
- `jq` is available for JSON parsing
