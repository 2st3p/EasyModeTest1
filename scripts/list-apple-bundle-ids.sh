#!/usr/bin/env bash
#
# Prints bundle IDs and team ID from easy-mode.xcodeproj so you can paste them into
# Apple Developer (Certificates, Identifiers & Profiles) without hunting in Xcode.
#
# Usage: from repo root: ./scripts/list-apple-bundle-ids.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PBX="${ROOT}/easy-mode.xcodeproj/project.pbxproj"

if [[ ! -f "${PBX}" ]]; then
  echo "error: missing ${PBX}" >&2
  exit 1
fi

echo "=== Development team (DEVELOPMENT_TEAM in project) ==="
grep -F 'DEVELOPMENT_TEAM = ' "${PBX}" | sed -n 's/.*DEVELOPMENT_TEAM = \([^;]*\);/\1/p' | sort -u
echo

echo "=== Bundle IDs (PRODUCT_BUNDLE_IDENTIFIER) — register each in Identifiers ==="
grep -F 'PRODUCT_BUNDLE_IDENTIFIER = ' "${PBX}" | sed -n 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);/\1/p' | sort -u
echo

echo "=== App Group (from Easymode.entitlements — must exist under Identifiers → App Groups) ==="
echo "group.com.easymode.shared"
echo

echo "Tip: create the App Group first, then each App ID and attach the same group + capabilities below."
echo "See docs/APPLE_DEVELOPER.md for the full checklist."
