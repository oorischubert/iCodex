
# iCodex

Fork of the original [Remodex](https://github.com/Emanuele-web04/remodex) project by Emanuele Di Pietro. Thanks for open sourcing your work!

Control [Codex](https://openai.com/codex/) from your iPhone while keeping the actual runtime on your Mac.

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

1. use the managed local relay on your Mac with `icodex up` on macOS
2. self-host a relay yourself
3. expose that relay over Tailscale or another private network

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
- a relay path, either the managed local relay on macOS or your own self-hosted relay

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

## Bridge Commands

### macOS default: managed local relay + background bridge

If you do not set `ICODEX_RELAY`, `icodex up` on macOS now starts a managed local relay and the bridge service together. The service keeps running after you close the terminal.

```sh
icodex up
```

Useful follow-up commands:

```sh
icodex status
icodex stop
```

By default the managed local relay listens on `0.0.0.0:9000` and advertises a relay URL like `ws://<your-mac>.local:9000/relay` in the QR code.

Optional overrides:

```sh
ICODEX_LOCAL_RELAY_HOSTNAME="192.168.1.10" icodex up
ICODEX_LOCAL_RELAY_BIND_HOST="127.0.0.1" ICODEX_LOCAL_RELAY_PORT="9100" icodex up
```

### External relay

To point the bridge at an explicit relay URL instead, set `ICODEX_RELAY`:

```sh
ICODEX_RELAY="ws://127.0.0.1:9000/relay" icodex up
```

`REMODEX_RELAY` is still accepted as a compatibility fallback, but new docs and scripts should use `ICODEX_RELAY`.

If you did not run `npm link`, use:

```sh
cd phodex-bridge
node ./bin/icodex.js up
```

On macOS, `icodex up` installs or refreshes the background bridge service and prints the QR pairing code. On other platforms, `icodex up` still runs in the foreground and expects an explicit relay URL.

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

1. Run `cd phodex-bridge && npm install && npm link`.
2. On macOS, run `icodex up`.
3. Open the iPhone app.
4. Scan the QR.
5. Close the terminal if you want; the managed macOS service keeps running in the background.

For a Tailscale or other self-hosted relay, set `ICODEX_RELAY="..."` before `icodex up`.

## Notes

- There is no bundled production relay in this fork.
- There is no supported global published-package install flow anymore.
- Source installs support `npm link` so you can use `icodex up` directly.
- On macOS, `icodex up` defaults to a managed local relay when `ICODEX_RELAY` is unset.
- The canonical local bridge state now lives under `~/.icodex`.
- Desktop refresh remains opt-in.

## More Docs

- [SELF_HOSTING_MODEL.md](SELF_HOSTING_MODEL.md)
- [Docs/self-hosting.md](Docs/self-hosting.md)
