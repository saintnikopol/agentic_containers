#!/bin/sh
# vix needs its daemon (vixd) running before the vix CLI can be used.
# Start it in the background, then hand off to whatever command was
# requested (bash by default, per docker-compose.yml).
set -e

if command -v vixd >/dev/null 2>&1; then
  vixd >/home/vix/.vixd.log 2>&1 &
fi

exec "$@"
