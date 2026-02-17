#!/bin/sh
if [ "$1" = "--auth" ]; then
  # Run auth command
  exec bun run dist/main.js auth
else
  # Default command
  if [ -n "$GH_TOKEN" ]; then
    exec bun run dist/main.js start --github-token "$GH_TOKEN" "$@"
  else
    exec bun run dist/main.js start "$@"
  fi
fi

