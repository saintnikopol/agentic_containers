
# Agent Sandbox for `iso` Monorepo (Vix) — DRAFT, UNTESTED

This directory follows the same pattern as `pi-code/` and `omp/`
(non-root user, `cap_drop: ALL`, bind-mounted `gitconfig`, token-based
clone, `setup.sh`), but for [Vix](https://getvix.dev) instead of Pi.

**Not build-verified yet.** Known unknowns before treating this as
working:

- Whether `getvix.dev/install.sh` needs root or installs cleanly as a
  non-root user into `~/.local/bin` (assumed here, unconfirmed).
- The actual `vixd` (daemon) / `vix` (CLI) relationship — `entrypoint.sh`
  assumes starting `vixd` in the background before handing off to the
  shell is sufficient, but this hasn't been exercised end-to-end.
- Exact required environment variables beyond `ANTHROPIC_API_KEY`.

Base image is `debian:bookworm-slim` rather than `node:24-bookworm`
since Vix is a standalone Go binary with no Node/npm dependency.

Before relying on this, run through the same verification pattern used
for `pi-code/` and `omp/`: build the image, run it with
`--cap-drop ALL --security-opt no-new-privileges:true`, confirm `id`
shows a non-root uid, and confirm `vix`/`vixd` actually start correctly.
