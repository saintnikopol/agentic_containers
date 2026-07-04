# Agentic Containers

Sandboxed, containerized environments for running AI coding agents (Pi,
oh-my-pi, Vix, ...) against a single git repository, with a fixed set of
provided API keys and nothing else from the host.

Each agent gets its own top-level directory (`pi-code/`, `omp/`, `vix/`,
...), fully self-contained: `Dockerfile`, `docker-compose.yml`,
`.env.example`, `.gitignore`, `README.md`, and a `setup.sh` that copies
the container files into a target repo checkout. This document explains
the rationale shared across all of them, so new agent containers stay
consistent instead of re-deriving the security posture from scratch.

## Threat model

The agent runs semi-trusted: it has write access to a repo and live API
keys, and it can be steered by content it reads (a prompt injection
hidden in an issue, a PR description, a fetched web page). The container
exists to bound what happens if that steering succeeds or a dependency
turns out to be malicious — not to prevent the agent from doing its job.

## Decisions and why

**Filesystem scope: only the target repo, nothing else from the host.**
The container bind-mounts a single host-cloned repo directory and
nothing else — no `~/.ssh`, `~/.aws`, `~/.config`, no Docker socket. If
the agent or something it runs goes rogue, there's nothing else on the
host for it to reach.

**Network access is open, deliberately.** The agent needs it to install
packages, call the LLM provider, and use `git`/`gh`. We don't proxy or
firewall egress. This is an accepted tradeoff, not an oversight: the
GitHub token is a fine-grained PAT scoped to exactly one repository, and
LLM API keys are treated as "may leak" — the blast radius of a leaked,
single-repo-scoped token is bounded by design, so restricting network
egress on top buys little for the operational cost it adds.

**Non-root user + dropped capabilities, regardless of the above.** This
is a *different* risk axis from credential leakage: it bounds what a
compromised dependency (e.g. a malicious `npm` postinstall script) can
do to the container itself, not what data it can exfiltrate. Every
container runs as a non-root user with `cap_drop: [ALL]` and
`no-new-privileges`. `no-new-privileges` alone is not sufficient — it
only blocks privilege *escalation*, and does nothing if the process
already starts as root, which is why the non-root user matters
independently.

**Docker Desktop's VM boundary is a mitigating layer, not a substitute
for the above.** Root-in-container escaping to Docker Desktop's Linux VM
is contained short of the actual Mac host, but (a) most realistic damage
happens *inside* the container without any escape at all, (b) Docker
Desktop's file-sharing already grants that VM access to a broad host
path (typically your whole home directory), and (c) the VM is shared
across every container you run, not isolated per project. It reduces
severity; it doesn't remove the need for non-root + capability drops.

**Git identity lives outside the image, per machine.** Each container
expects a `gitconfig` file (git `user.name`/`user.email`) bind-mounted
in from the host, gitignored so it never becomes part of the target
repo's history. Identity is personal, not something that belongs baked
into a shared image. `setup.sh` offers to default this to whatever git
identity is already effective for the target repo (local or global),
with the option to override it.

**Repo access: host clones, container bind-mounts.** You `git clone`
the target repo on the host yourself (using a token-authenticated URL so
`git push` keeps working without extra credential wiring), then the
compose file bind-mounts that folder in. The alternative — an entrypoint
script that auto-clones into a Docker-managed volume — would make the
container more self-contained, but was set aside in favor of the
simpler, more transparent host-clone approach for now.

**`setup.sh` exists to keep repos consistent, not to hide what's
happening.** It copies the Dockerfile/compose files, merges required
`.gitignore` entries into the target repo without clobbering its
existing one, and prompts for git identity. It does *not* silently
create secrets — `.env` is only ever templated from `.env.example`, you
fill in real values yourself.

## Containers

| Directory | Agent | Status |
|---|---|---|
| `pi-code/` | [Pi](https://pi.dev) coding agent | Hardened: non-root, `cap_drop: ALL`, verified end-to-end |
| `omp/` | [oh-my-pi](https://www.npmjs.com/package/oh-my-pi) (multi-agent orchestration layer on top of Pi) | Same hardening as `pi-code/`, plus the `oh-my-pi` extension |
| `vix/` | [Vix](https://getvix.dev) coding agent | Draft, **not build-verified** — see `vix/README.md` |
