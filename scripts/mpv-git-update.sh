#!/usr/bin/env bash
# mpv-git-update.sh
#
# Prints the current mpv-player/mpv master commit's rev, hash, and a
# suggested version string, formatted to paste directly into
# overlays/mpv-git.nix's `gitRev` / `gitHash` / `gitVersion` bindings.
#
# Requires: nix-prefetch-github (add pkgs.nix-prefetch-github to
# environment.systemPackages), jq.
#
# This script only prints — it does not edit mpv-git.nix itself.

set -euo pipefail

OWNER="mpv-player"
REPO="mpv"
BRANCH="master"

if ! command -v nix-prefetch-github >/dev/null 2>&1; then
  echo "error: nix-prefetch-github not found on PATH." >&2
  echo "Add pkgs.nix-prefetch-github to environment.systemPackages and rebuild." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq not found on PATH." >&2
  echo "Add pkgs.jq to environment.systemPackages and rebuild, or run:" >&2
  echo "  nix shell nixpkgs#jq --command $0 $*" >&2
  exit 1
fi

echo "Fetching latest commit info for ${OWNER}/${REPO}@${BRANCH}..." >&2

# nix-prefetch-github --rev <branch> resolves the branch to its current
# tip commit and prefetches that, printing {owner, repo, rev, hash} as JSON.
result="$(nix-prefetch-github --rev "$BRANCH" --json "$OWNER" "$REPO")"

rev="$(echo "$result" | jq -r '.rev')"
hash="$(echo "$result" | jq -r '.hash')"
short_rev="${rev:0:7}"

cat <<EOF

Paste into overlays/mpv-git.nix:

  gitRev = "${short_rev}";
  gitHash = "${hash}";

Full commit: ${rev}
Compare: https://github.com/${OWNER}/${REPO}/compare/${short_rev}...master
EOF
