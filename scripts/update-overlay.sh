#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  update-overlay.sh <package> <version>

Examples:
  update-overlay.sh faugus-launcher 2.3.0
  update-overlay.sh foo 1.4.1
  update-overlay.sh mpv-git 0123456789abcdef0123456789abcdef01234567

Package metadata format:
  [name]="owner:repo:ref_type:tag_prefix:overlay_file"

ref_type:
  tag  - version is a release version; Git ref is tag_prefix + version
  rev  - version is passed directly as the Git revision

tag_prefix:
  Empty for tags like 1.2.3
  v for tags like v1.2.3
EOF
}

package="${1:-}"
version="${2:-}"

[[ -n "$package" && -n "$version" ]] || {
  usage >&2
  exit 2
}

flake_dir="$HOME/nixos"
overlay_dir="$flake_dir/overlays"

[[ -d "$overlay_dir" ]] || {
  printf 'Overlay directory not found: %s\n' "$overlay_dir" >&2
  exit 1
}

declare -A packages=(
  # name="owner:repo:ref_type:tag_prefix:overlay_file"

  # Tags are literally 2.3.0, 2.2.2, etc.
  [faugus-launcher]="Faugus:faugus-launcher:tag::$overlay_dir/faugus-launcher.nix"

  # Example: upstream tags are v1.2.3, but keep Nix version as 1.2.3.
  # [example-tool]="example-owner:example-tool:tag:v:$overlay_dir/example-tool.nix"

  # Example: pass a commit SHA, branch, or arbitrary Git ref directly.
  # [some-git-package]="some-owner:some-repo:rev::$overlay_dir/some-git-package.nix"
)

metadata="${packages[$package]:-}"

[[ -n "$metadata" ]] || {
  printf 'Unknown package: %s\n\nKnown packages:\n' "$package" >&2
  printf '  %s\n' "${!packages[@]}" | sort >&2
  exit 2
}

IFS=: read -r owner repo ref_type tag_prefix file <<< "$metadata"

[[ -n "$owner" && -n "$repo" && -n "$ref_type" && -n "$file" ]] || {
  printf 'Invalid metadata for package: %s\n' "$package" >&2
  exit 1
}

[[ -f "$file" ]] || {
  printf 'Overlay file not found: %s\n' "$file" >&2
  exit 1
}

case "$ref_type" in
  tag)
    git_ref="${tag_prefix}${version}"
    ;;
  rev)
    git_ref="$version"
    ;;
  *)
    printf 'Invalid ref_type for %s: %s (expected tag or rev)\n' \
      "$package" "$ref_type" >&2
    exit 1
    ;;
esac

version_matches="$(
  grep -Ec '^[[:space:]]*version = "[^"]+";[[:space:]]*$' "$file" || true
)"

hash_matches="$(
  grep -Ec '^[[:space:]]*hash = "sha256-[^"]+";[[:space:]]*$' "$file" || true
)"

[[ "$version_matches" -eq 1 ]] || {
  printf 'Expected exactly one literal version = "..."; line in: %s\n' "$file" >&2
  printf 'Found: %s\n' "$version_matches" >&2
  exit 1
}

[[ "$hash_matches" -eq 1 ]] || {
  printf 'Expected exactly one literal hash = "sha256-..."; line in: %s\n' "$file" >&2
  printf 'Found: %s\n' "$hash_matches" >&2
  exit 1
}

hash="$(
  nix-prefetch-github "$owner" "$repo" --rev "$git_ref" |
    jq -er '.hash'
)"

[[ "$hash" =~ ^sha256-[A-Za-z0-9+/]+={0,2}$ ]] || {
  printf 'Invalid hash returned for %s/%s at ref %s:\n%s\n' \
    "$owner" "$repo" "$git_ref" "$hash" >&2
  exit 1
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

sed \
  -e "s/version = \"[^\"]*\";/version = \"$version\";/" \
  -e "s|hash = \"sha256-[^\"]*\";|hash = \"$hash\";|" \
  "$file" > "$tmp"

new_version_matches="$(
  grep -Ec "^[[:space:]]*version = \"${version}\";[[:space:]]*$" "$tmp" || true
)"

new_hash_matches="$(
  grep -Ec "^[[:space:]]*hash = \"${hash}\";[[:space:]]*$" "$tmp" || true
)"

[[ "$new_version_matches" -eq 1 ]] || {
  printf 'Refusing to write: version replacement did not produce one expected line.\n' >&2
  exit 1
}

[[ "$new_hash_matches" -eq 1 ]] || {
  printf 'Refusing to write: hash replacement did not produce one expected line.\n' >&2
  exit 1
}

if cmp -s "$file" "$tmp"; then
  printf 'No changes needed for %s.\n' "$package"
  exit 0
fi

cp "$tmp" "$file"

printf 'Updated %s\n' "$package"
printf '  file:     %s\n' "$file"
printf '  source:   %s/%s\n' "$owner" "$repo"
printf '  %s:      %s\n' "$ref_type" "$git_ref"
printf '  version:  %s\n' "$version"
printf '  hash:     %s\n' "$hash"

printf '\nChanged lines:\n'
git -C "$flake_dir" diff -- "$file" || true