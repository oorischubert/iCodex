#!/usr/bin/env node
// FILE: icodex.js
// Purpose: CLI surface for foreground bridge runs, pairing reset, thread resume, and macOS service control.
// Layer: CLI binary
// Exports: none
// Depends on: ../src

const {
  printMacOSBridgePairingQr,
  printMacOSBridgeServiceStatus,
  readBridgeConfig,
  resetMacOSBridgePairing,
  runMacOSBridgeService,
  startBridge,
  startMacOSBridgeService,
  stopMacOSBridgeService,
  resetBridgePairing,
  openLastActiveThread,
  watchThreadRollout,
} = require("../src");
const { version } = require("../package.json");

const command = process.argv[2] || "up";

void main();

async function main() {
  if (isVersionCommand(command)) {
    console.log(version);
    return;
  }

  if (command === "up") {
    if (process.platform === "darwin") {
      const result = await startMacOSBridgeService({
        waitForPairing: true,
      });
      printMacOSBridgePairingQr({
        pairingSession: result.pairingSession,
      });
      return;
    }

    startBridge();
    return;
  }

  if (command === "run") {
    startBridge();
    return;
  }

  if (command === "run-service") {
    runMacOSBridgeService();
    return;
  }

  if (command === "start") {
    assertMacOSCommand(command);
    readBridgeConfig();
    await startMacOSBridgeService({
      waitForPairing: false,
    });
    console.log("[icodex] macOS bridge service is running.");
    return;
  }

  if (command === "stop") {
    assertMacOSCommand(command);
    stopMacOSBridgeService();
    console.log("[icodex] macOS bridge service stopped.");
    return;
  }

  if (command === "status") {
    assertMacOSCommand(command);
    printMacOSBridgeServiceStatus();
    return;
  }

  if (command === "reset-pairing") {
    try {
      if (process.platform === "darwin") {
        resetMacOSBridgePairing();
        console.log("[icodex] Stopped the macOS bridge service and cleared the saved pairing state. Run `icodex up` to pair again.");
      } else {
        resetBridgePairing();
        console.log("[icodex] Cleared the saved pairing state. Run `icodex up` to pair again.");
      }
    } catch (error) {
      console.error(`[icodex] ${(error && error.message) || "Failed to clear the saved pairing state."}`);
      process.exit(1);
    }
    return;
  }

  if (command === "resume") {
    try {
      const state = openLastActiveThread();
      console.log(
        `[icodex] Opened last active thread: ${state.threadId} (${state.source || "unknown"})`
      );
    } catch (error) {
      console.error(`[icodex] ${(error && error.message) || "Failed to reopen the last thread."}`);
      process.exit(1);
    }
    return;
  }

  if (command === "watch") {
    try {
      watchThreadRollout(process.argv[3] || "");
    } catch (error) {
      console.error(`[icodex] ${(error && error.message) || "Failed to watch the thread rollout."}`);
      process.exit(1);
    }
    return;
  }

  console.error(`Unknown command: ${command}`);
  console.error(
    "Usage: icodex up | icodex run | icodex start | icodex stop | icodex status | "
    + "icodex reset-pairing | icodex resume | icodex watch [threadId] | icodex --version"
  );
  process.exit(1);
}

function assertMacOSCommand(name) {
  if (process.platform === "darwin") {
    return;
  }

  console.error(`[icodex] \`${name}\` is only available on macOS. Use \`icodex up\` or \`icodex run\` for the foreground bridge on this OS.`);
  process.exit(1);
}

function isVersionCommand(value) {
  return value === "-v" || value === "--v" || value === "-V" || value === "--version" || value === "version";
}
