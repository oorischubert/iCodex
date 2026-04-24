#!/usr/bin/env node
// FILE: icodex.js
// Purpose: iCodex CLI alias for the upstream Remodex bridge command.
// Layer: CLI binary
// Exports: none
// Depends on: ./remodex

const { main } = require("./remodex");

void main();
