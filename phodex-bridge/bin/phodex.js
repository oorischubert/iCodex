#!/usr/bin/env node
// FILE: phodex.js
// Purpose: Backward-compatible wrapper that forwards legacy `phodex` usage to `icodex`.
// Layer: CLI binary
// Exports: none
// Depends on: ./icodex

require("./icodex");
