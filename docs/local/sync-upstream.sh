#!/usr/bin/env bash
# Sync local/dev with upstream master.
# Safe to run at any time — stashes and restores uncommitted changes automatically.
set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"
cd "$REPO"

echo "[sync-upstream] Fetching origin..."
git fetch origin --quiet

NEW=$(git log local/dev..origin/master --oneline | wc -l | tr -d ' ')

if [ "$NEW" -eq 0 ]; then
    echo "[sync-upstream] Already up to date ($(git rev-parse --short origin/master))."
    exit 0
fi

echo "[sync-upstream] $NEW new commit(s) from upstream."

# Stash everything (tracked + untracked) if the working tree is dirty
STASH_NAME="sync-upstream auto-stash $(date +%Y%m%d-%H%M%S)"
STASHED=0
if ! git diff --quiet || ! git diff --cached --quiet || \
   [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "[sync-upstream] Stashing local changes..."
    git stash push --include-untracked -m "$STASH_NAME"
    STASHED=1
fi

# Fast-forward master to upstream HEAD
echo "[sync-upstream] Updating master..."
git checkout master --quiet
git merge --ff-only origin/master --quiet

# Rebase local/dev on top of updated master
echo "[sync-upstream] Rebasing local/dev..."
git checkout local/dev --quiet
if ! git rebase master; then
    echo ""
    echo "[sync-upstream] ERROR: rebase had conflicts."
    echo "  Resolve with:  git status  →  edit conflicted files  →  git rebase --continue"
    echo "  Or abort with: git rebase --abort"
    if [ "$STASHED" -eq 1 ]; then
        echo "  Your stash is preserved: git stash list"
    fi
    exit 1
fi

# Restore stash (conflicts here mean upstream touched your local changes)
if [ "$STASHED" -eq 1 ]; then
    echo "[sync-upstream] Restoring local changes..."
    if ! git stash pop; then
        echo ""
        echo "[sync-upstream] WARNING: stash pop had conflicts on some files."
        echo "  Resolve with:  git status  →  edit conflicted files  →  git add <file>"
        echo "  The stash entry is kept — run 'git stash drop' once resolved."
        exit 1
    fi
fi

LOCAL=$(git log master..local/dev --oneline | wc -l | tr -d ' ')
echo "[sync-upstream] Done — $(git rev-parse --short HEAD)."
echo "  Integrated : $NEW upstream commit(s)"
echo "  Local ahead: $LOCAL commit(s) on top of master"
