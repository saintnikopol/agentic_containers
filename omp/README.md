
# Agent Sandbox for `iso` Monorepo (oh-my-pi)

Minimal, containerized environment for running [Pi](https://pi.dev)
enhanced with [oh-my-pi](https://www.npmjs.com/package/oh-my-pi) — a
multi-agent orchestration layer on top of Pi — against the private `iso`
repo. Same hardening as the plain `pi-code/` container (non-root user,
dropped capabilities); the only difference is the extra extension.

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

Place `Dockerfile`, `docker-compose.yml`, `.env` (copy from
`.env.example`), and `gitconfig` in `iso/`. You can either create them by
hand, or run the setup script from this repo:

```bash
sh /path/to/omp/setup.sh iso/
```

It copies the Dockerfile/compose files, merges the required `.gitignore`
entries (`.env`, `gitconfig`) into `iso/`'s existing `.gitignore` without
overwriting it, and prompts to create `gitconfig` — offering your current
git identity (`user.name`/`user.email`) as the default, or letting you
enter a different name/email if you want the container to commit as
someone else. `gitconfig` is bind-mounted into the container as
`/home/node/.gitconfig` so commits have an author identity, and it's
gitignored so it stays local to your machine.

Either way, fill in `.env` with real values:

```
GITHUB_TOKEN=github_pat_..      # your fine‑grained PAT for the target repo
OPENAI_API_KEY=sk-or..          # your OpenAI or open-router api key
DEEPSEEK_API_KEY=sk-9b..        # deepseek API key for agent to use
ANTHROPIC_API_KEY=sk-ant-..     # optional - oh-my-pi's example specialist agents (e.g. "oracle") default to Claude models
```

Build and run:
```bash
docker compose build
docker compose up -d
docker compose exec agent bash
```

## 🤖 oh-my-pi

oh-my-pi replaces Pi's default system prompt with an orchestrator that
routes work to specialist sub-agents (oracle, librarian, explore) and
follows more structured workflows. It's installed at image build time
via Pi's own package manager (`pi install npm:oh-my-pi` — note the
`npm:` prefix; the package's own README omits it, but Pi's `install`
command requires a source type) and activates automatically on your
first `pi` session — no separate command needed.

Optional per-project config, `.oh-my-pi.jsonc` in `iso/`:
```jsonc
{
  "orchestrator": {
    "agentName": "my-agent",
    "promptTemplate": "sisyphus"
  }
}
```

Run `/oh-my-pi doctor` inside a `pi` session to check it loaded correctly.

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

That's it – secure, focused, and ready for your agent.
