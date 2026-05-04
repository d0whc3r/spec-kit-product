#!/usr/bin/env bash
# Product extension: resolve-feature-dir.sh
# Resolve the active feature directory for /speckit-product-spec.
#
# Reads `.specify/feature.json#feature_directory`, validates it points to an
# existing directory, and prints the absolute path on stdout.
#
# Exit codes:
#   0  success; absolute path on stdout
#   2  E_NO_PROJECT  no .specify/ directory found in any ancestor
#   3  E_NO_POINTER  .specify/feature.json missing or unreadable
#   4  E_BAD_POINTER feature_directory empty or points to non existent dir
#
# Usage: resolve-feature-dir.sh [--feature-dir <path>]
#   --feature-dir <path>  override the pointer with an explicit absolute or
#                         repo relative path. Useful when the pointer is
#                         missing or stale.

set -e

OVERRIDE=""
while [ $# -gt 0 ]; do
    case "$1" in
        --feature-dir)
            OVERRIDE="$2"
            shift 2
            ;;
        --feature-dir=*)
            OVERRIDE="${1#*=}"
            shift
            ;;
        *)
            echo "[product] unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

_find_project_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

PROJECT_ROOT=$(_find_project_root "$(pwd)") || {
    echo "[product] E_NO_PROJECT: no .specify/ directory found in any ancestor of $(pwd)" >&2
    exit 2
}

if [ -n "$OVERRIDE" ]; then
    case "$OVERRIDE" in
        /*) RESOLVED="$OVERRIDE" ;;
        *)  RESOLVED="$PROJECT_ROOT/$OVERRIDE" ;;
    esac
else
    POINTER="$PROJECT_ROOT/.specify/feature.json"
    if [ ! -f "$POINTER" ]; then
        echo "[product] E_NO_POINTER: $POINTER not found. Run /speckit-specify first or pass --feature-dir." >&2
        exit 3
    fi

    FEATURE_DIR=$(grep -o '"feature_directory"[[:space:]]*:[[:space:]]*"[^"]*"' "$POINTER" \
        | sed 's/.*:[[:space:]]*"\([^"]*\)"/\1/')

    if [ -z "$FEATURE_DIR" ]; then
        echo "[product] E_NO_POINTER: feature_directory missing from $POINTER. Pass --feature-dir to override." >&2
        exit 3
    fi

    case "$FEATURE_DIR" in
        /*) RESOLVED="$FEATURE_DIR" ;;
        *)  RESOLVED="$PROJECT_ROOT/$FEATURE_DIR" ;;
    esac
fi

if [ ! -d "$RESOLVED" ]; then
    echo "[product] E_BAD_POINTER: feature directory does not exist: $RESOLVED" >&2
    exit 4
fi

# Canonicalise to an absolute path without symlink resolution requirements.
ABS=$(cd "$RESOLVED" && pwd)
echo "$ABS"
