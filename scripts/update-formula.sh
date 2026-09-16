#!/usr/bin/env bash
# Updates Formula/firecracker.rb to the latest upstream release.
# Prints the new tag on stdout if the formula changed, nothing otherwise.
set -euo pipefail

REPO="firecracker-microvm/firecracker"
FORMULA="$(cd "$(dirname "$0")/.." && pwd)/Formula/firecracker.rb"

# Resolve the "latest" release via redirect - no API token or rate limit needed.
latest_tag="$(basename "$(curl -fsSIL -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest")")"
[[ "$latest_tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Unexpected tag: $latest_tag" >&2; exit 1; }

current_tag="$(grep -oE 'download/v[0-9]+\.[0-9]+\.[0-9]+/' "$FORMULA" | head -1 | sed -E 's#download/(.*)/#\1#')"

if [[ "$latest_tag" == "$current_tag" ]]; then
  echo "Formula already at $current_tag" >&2
  exit 0
fi

echo "Updating $current_tag -> $latest_tag" >&2

for arch in x86_64 aarch64; do
  asset="firecracker-${latest_tag}-${arch}.tgz"
  url="https://github.com/${REPO}/releases/download/${latest_tag}/${asset}"

  # Upstream publishes <asset>.sha256.txt; verify it against the real download.
  published="$(curl -fsSL "${url}.sha256.txt" | awk '{print $1}')"
  actual="$(curl -fsSL "$url" | sha256sum | awk '{print $1}')"
  if [[ "$published" != "$actual" ]]; then
    echo "Checksum mismatch for $asset (published $published, actual $actual)" >&2
    exit 1
  fi

  # Replace the sha256 on the line directly after this arch's url line.
  sed -i -E "/${arch}\.tgz\"/{n;s/sha256 \"[0-9a-f]+\"/sha256 \"${actual}\"/}" "$FORMULA"
done

# Bump the tag everywhere it appears (only in the two download URLs).
sed -i "s|${current_tag}|${latest_tag}|g" "$FORMULA"

echo "$latest_tag"
