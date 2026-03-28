#!/usr/bin/env node
// FILE: remodex.js
// Purpose: Backward-compatible wrapper that forwards legacy `remodex` usage to `icodex`.
// Layer: CLI binary
// Exports: none
// Depends on: ./icodex

require("./icodex");
