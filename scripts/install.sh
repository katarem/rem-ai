#!/usr/bin/env bash
# Backwards-compatible entry point: delegates to `rem-ai install` with the same arguments.
set -euo pipefail

exec "${BASH:-bash}" "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/rem-ai" install "$@"
