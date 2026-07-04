
# Agent Sandbox for `iso` Monorepo

Minimal, containerized environment for running an AI coding agent against the private `iso` repo.

## 🔐 Required GitHub Token

Create a [fine‑grained PAT](https://github.com/settings/tokens?type=beta) with:

- **Repository access:** Only `iso`
- **Permissions:**  
  - `Contents` → Read & Write  
  - `Pull requests` → Read & Write  
  - `Metadata` → Read

## 🚀 Setup (one time)

Create a fine‑grained GitHub token first (see above), then clone using the
token so both `git clone` and later `git push` authenticate automatically —
no separate credential setup needed:

```bash
export GITHUB_TOKEN=github_pat_..
git clone https://x-access-token:${GITHUB_TOKEN}@github.com/your-org/iso.git
cd iso
```

Place these three files in `iso/`:

**`Dockerfile`**
```

**`docker-compose.yml`**

**`.env`** (copy from .env.example)
```
GITHUB_TOKEN=github_pat_..      # your fine‑grained PAT for the target repo
OPENAI_API_KEY=sk-or..          # your OpenAI or open-router api key
DEEPSEEK_API_KEY=sk-9b..        # deepseek API key for agent to use
```

Create a finegrained github token, with access only to the target repo.
Pick LLM provider of your choice. 

Also create a `gitconfig` file next to `docker-compose.yml` (this is
bind-mounted into the container as `/root/.gitconfig` so commits have an
author identity — it's gitignored, so it stays local to your machine):

```bash
cat > gitconfig <<'EOF'
[user]
    name = Your Name
    email = you@example.com
EOF
```

Build and run:
```bash
docker compose build
docker compose up -d
docker compose exec agent bash
```

## 🛠️ Inside the container

```bash
# Create a branch, make changes, push
git checkout -b agent/feature
echo "update" >> file.txt
git add .
git commit -m "Agent commit"
git push origin agent/feature

# Create a PR (GitHub CLI)
gh pr create --title "Feature" --body "Automated PR" --base main
```

## 🔒 Security notes

- The GitHub token can only access the `iso` repository.
- The container sees **only** the mounted `iso` folder.
- Your `main` branch on GitHub should be **protected** (require PRs, reviews). The agent never pushes directly to `main`.

---

That’s it – secure, focused, and ready for your agent.
```