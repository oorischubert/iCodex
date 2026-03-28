<p align="center">
  <img src="CodexMobile/CodexMobile/Assets.xcassets/remodex-og1.imageset/remodex-og2%20%281%29.png" alt="iCodex" />
</p>

# iCodex

Control [Codex](https://openai.com/index/codex/) from your iPhone while keeping the actual runtime on your Mac.

iCodex is local-first:

- the iPhone is a remote client
- the bridge runs on your Mac
- Codex runs on your Mac
- git and workspace actions run on your Mac
- the relay is only transport

This fork does not ship with:

- a built-in hosted relay
- an App Store paywall flow
- npm-published bridge install assumptions

The supported paths are:

1. self-host a relay yourself
2. expose that relay over Tailscale or another private network

## Architecture

```text
iCodex iPhone app <-> relay <-> iCodex bridge on Mac <-> codex app-server
```

The bridge is the important integration layer. It:

- owns secure QR pairing and trusted reconnect
- forwards JSON-RPC to `codex app-server`
- handles local git/workspace actions
- keeps thread/session state on your Mac

## Repository Layout

```text
phodex-bridge/   Node bridge and CLI
CodexMobile/     iOS app source
relay/           Self-hostable relay and optional push service
```

## Prerequisites

- Node.js 18+
- [Codex CLI](https://github.com/openai/codex) installed and working on your Mac
- Xcode 16+ if you are building the iPhone app from source
- your own relay deployment, either local or reachable over Tailscale

## iPhone App

Build the app from source in Xcode and install your own signed build on device.

The app is now branded as `iCodex` and the in-app purchase gate has been removed for this fork.

## Bridge Setup

Install the bridge CLI from source:

```sh
cd phodex-bridge
npm install
npm link
```

That gives you the `icodex` command locally on your Mac, so you can use `icodex up` the same way the old project used `remodex up`.

If you do not want to link the CLI globally, you can still run the source entrypoint directly:

```sh
cd phodex-bridge
npm install
node ./bin/icodex.js up
```

## Local Quick Start

If you want the old all-in-one local test flow back, use the launcher from the repo root:

```sh
./run-local-icodex.sh
```

That script:

- installs missing relay and bridge dependencies
- starts the local relay on port `9000`
- points the bridge at `ws://<your-host>:9000/relay`
- runs `icodex up`
- prints the pairing QR for the iPhone app

Compatibility note:

- `./run-local-remodex.sh` still works and forwards to `./run-local-icodex.sh`

Common options:

```sh
./run-local-icodex.sh --hostname 192.168.1.10
./run-local-icodex.sh --bind-host 127.0.0.1 --port 9100
```

## Bridge Commands

Start the bridge with an explicit relay URL:

```sh
ICODEX_RELAY="ws://127.0.0.1:9000/relay" icodex up
```

`REMODEX_RELAY` is still accepted as a compatibility fallback, but new docs and scripts should use `ICODEX_RELAY`.

If you did not run `npm link`, use:

```sh
cd phodex-bridge
ICODEX_RELAY="ws://127.0.0.1:9000/relay" node ./bin/icodex.js up
```

On macOS, `icodex up` installs or refreshes the background bridge service and prints the QR pairing code. On other platforms, the same command runs in the foreground.

## Relay Setup

Run the relay yourself. For a local relay:

```sh
cd relay
npm install
npm start
```

By default the relay listens on port `9000`.

Health check:

```sh
curl http://127.0.0.1:9000/health
```

Expected response:

```json
{"ok":true}
```

## Recommended Network Model

For regular iPhone use, prefer a Tailscale-reachable relay instead of plain LAN-only routing.

A typical setup is:

1. run the relay on a Mac, mini server, or VPS you control
2. put that machine on Tailscale
3. set `ICODEX_RELAY` to the relay's `ws://` or `wss://` URL
4. pair once by scanning the QR
5. let trusted reconnect reuse that same relay later

## Quick Start

1. For a fully local setup, run `./run-local-icodex.sh`.
2. For a self-hosted or Tailscale relay, run `cd phodex-bridge && npm install && npm link`.
3. Start the bridge with `ICODEX_RELAY="..." icodex up`.
4. Open the iPhone app.
5. Scan the QR.

## Notes

- There is no bundled production relay in this fork.
- There is no supported global published-package install flow anymore.
- Source installs support `npm link` so you can use `icodex up` directly.
- The canonical local bridge state now lives under `~/.icodex`.
- Desktop refresh remains opt-in.

## More Docs

- [SELF_HOSTING_MODEL.md](SELF_HOSTING_MODEL.md)
- [Docs/self-hosting.md](Docs/self-hosting.md)
