#!/usr/bin/env bash
# Enforces the platform boundaries of the monorepo (see CLAUDE.md
# "Package Dependency Graph"):
#
#   kit_* + app_shared  → PURE DART: no Flutter, no Jaspr, no package:web, and
#                         no VM/Flutter-only SDK libraries (dart:io, dart:isolate,
#                         dart:ffi, dart:ui, dart:mirrors, dart:html). A VM-only
#                         implementation is allowed only in a file named
#                         *_io.dart / *_isolate.dart picked by a conditional export.
#   jaspr_kit_* + apps/web → no Flutter.
#   flutter_kit_*        → no Jaspr.
#
# A violation fails silently at runtime otherwise: e.g. one `import 'dart:isolate'`
# in app_shared makes dart2js skip the whole web entrypoint.
set -uo pipefail

cd "$(dirname "$0")/.."
fail=0

report() {
  echo "❌ $1"
  fail=1
}

scan() { # <label> <grep -E pattern> <dirs...>   (optional env: SCAN_IGNORE=<grep -E>)
  local label=$1 pattern=$2
  shift 2
  local hits
  hits=$(grep -rnE --include='*.dart' "$pattern" "$@" 2>/dev/null |
    grep -vE '_(io|isolate)\.dart:' |
    { if [ -n "${SCAN_IGNORE:-}" ]; then grep -vE "$SCAN_IGNORE"; else cat; fi; } || true)
  if [ -n "$hits" ]; then
    report "$label"
    echo "$hits" | sed 's/^/     /'
  fi
}

PURE_DIRS=()
for d in packages/kit_* packages/app_shared; do
  [ -d "$d/lib" ] && PURE_DIRS+=("$d/lib")
  if grep -qE '^\s+sdk:\s*flutter' "$d/pubspec.yaml"; then
    report "$d/pubspec.yaml depends on the Flutter SDK"
  fi
done

scan "Pure packages must not import Flutter / Jaspr / package:web" \
  "^\s*(import|export)\s+'package:(flutter|flutter_[a-z_]+|jaspr[a-z_]*|web)/" \
  "${PURE_DIRS[@]}"
scan "Pure packages must not import VM/Flutter-only SDK libraries" \
  "^\s*(import|export)\s+'dart:(io|isolate|ffi|ui|mirrors|html)'" \
  "${PURE_DIRS[@]}"

JASPR_DIRS=()
for d in packages/jaspr_kit_* apps/web apps/web_ssr_demo; do
  [ -d "$d/lib" ] && JASPR_DIRS+=("$d/lib")
  if grep -qE '^\s+sdk:\s*flutter' "$d/pubspec.yaml"; then
    report "$d/pubspec.yaml depends on the Flutter SDK"
  fi
done
# The web apps' own package names start with "flutter_base_kit…" — importing
# themselves (e.g. jaspr_builder's generated *.options.dart) is not Flutter.
SCAN_IGNORE="'package:flutter_base_kit_web[a-z_]*/" \
  scan "Jaspr packages must not import Flutter" \
  "^\s*(import|export)\s+'package:(flutter|flutter_[a-z_]+)/" \
  "${JASPR_DIRS[@]}"

FLUTTER_DIRS=()
for d in packages/flutter_kit_* apps/mobile; do
  [ -d "$d/lib" ] && FLUTTER_DIRS+=("$d/lib")
done
scan "Flutter packages must not import Jaspr" \
  "^\s*(import|export)\s+'package:jaspr[a-z_]*/" \
  "${FLUTTER_DIRS[@]}"

if [ $fail -eq 0 ]; then
  echo "✅ Package boundaries OK (pure: ${#PURE_DIRS[@]}, jaspr: ${#JASPR_DIRS[@]}, flutter: ${#FLUTTER_DIRS[@]})"
fi
exit $fail
