#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REMOTE_WIKI_URL="${1:-https://github.com/Simonsbs/l0.wiki.git}"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/l0_wiki_publish.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

# Ensure local wiki mirror is up to date first.
bash "$ROOT/scripts/sync_wiki.sh" >/tmp/l0_publish_wiki_sync.out
if ! grep -q '^ok$' /tmp/l0_publish_wiki_sync.out; then
  echo "error: local wiki sync failed" >&2
  exit 1
fi

if ! git clone "$REMOTE_WIKI_URL" "$TMP_DIR/wiki_repo" >/tmp/l0_publish_wiki_clone.out 2>/tmp/l0_publish_wiki_clone.err; then
  echo "error: cannot clone remote wiki repo ($REMOTE_WIKI_URL)" >&2
  cat /tmp/l0_publish_wiki_clone.err >&2
  echo "hint: enable GitHub Wiki in repository settings first" >&2
  exit 2
fi

cd "$TMP_DIR/wiki_repo"
if [ -z "$(git config user.email || true)" ]; then
  git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
fi
if [ -z "$(git config user.name || true)" ]; then
  git config user.name "github-actions[bot]"
fi
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -a "$ROOT/wiki/." .

if [ ! -f Home.md ]; then
  echo "error: generated wiki missing Home.md" >&2
  exit 1
fi

find . -type f -name '*.md' -exec chmod 0644 {} +

if git diff --quiet --exit-code && git diff --cached --quiet --exit-code; then
  echo "ok"
  exit 0
fi

git add .
git commit -m "Sync wiki from canonical docs"
git push origin master

echo "ok"
