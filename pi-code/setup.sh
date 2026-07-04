#!/bin/sh
# Copies the pi-code container files into a target repo checkout.
# Usage: sh setup.sh <target-repo-dir>
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ $# -ne 1 ]; then
  echo "Usage: sh $0 <target-repo-dir>" >&2
  exit 1
fi

TARGET="$1"

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory '$TARGET' does not exist" >&2
  exit 1
fi

if [ ! -d "$TARGET/.git" ]; then
  echo "Warning: '$TARGET' does not look like a git repository (no .git dir)" >&2
fi

cp "$SCRIPT_DIR/Dockerfile" "$TARGET/Dockerfile"
cp "$SCRIPT_DIR/docker-compose.yml" "$TARGET/docker-compose.yml"
echo "Copied Dockerfile and docker-compose.yml into $TARGET"

if [ -f "$TARGET/.env" ]; then
  echo "Skipping .env (already exists in target)"
else
  cp "$SCRIPT_DIR/.env.example" "$TARGET/.env"
  echo "Created $TARGET/.env from template - fill in your real token/keys"
fi

# Merge required entries into the target's own .gitignore rather than
# overwriting it, since the target repo likely already has one.
touch "$TARGET/.gitignore"
for entry in ".env" ".env.*" "!.env.example" "gitconfig"; do
  if ! grep -qxF "$entry" "$TARGET/.gitignore"; then
    echo "$entry" >> "$TARGET/.gitignore"
  fi
done
echo "Merged required entries into $TARGET/.gitignore"

cat <<EOF

Next steps:
  1. Edit $TARGET/.env with your real GITHUB_TOKEN / API keys
  2. Create $TARGET/gitconfig with your git identity (see README)
  3. cd $TARGET && docker compose build && docker compose up -d
EOF
