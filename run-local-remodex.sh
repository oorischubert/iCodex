#!/usr/bin/env bash

# FILE: run-local-remodex.sh
# Purpose: Backward-compatible wrapper that forwards the old launcher name to run-local-icodex.sh.
# Layer: developer utility
# Exports: none
# Depends on: ./run-local-icodex.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${ROOT_DIR}/run-local-icodex.sh" "$@"
