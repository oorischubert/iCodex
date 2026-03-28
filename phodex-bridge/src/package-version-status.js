// FILE: package-version-status.js
// Purpose: Reads the installed iCodex bridge version without consulting a package registry.
// Layer: CLI helper
// Exports: createBridgePackageVersionStatusReader
// Depends on: ../package.json

const { version: installedVersion = "" } = require("../package.json");

function createBridgePackageVersionStatusReader() {
  return async function readBridgePackageVersionStatus() {
    return {
      bridgeVersion: normalizeVersion(installedVersion) || null,
      bridgeLatestVersion: null,
    };
  };
}

function normalizeVersion(value) {
  return typeof value === "string" && value.trim() ? value.trim() : "";
}

module.exports = {
  createBridgePackageVersionStatusReader,
};
