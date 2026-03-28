# Self-Hosting iCodex

This guide assumes:

- you cloned this repository
- you will run your own relay
- you will pair the iPhone app with a Mac you control

There is no built-in hosted relay in this fork.

## Model

iCodex is local-first:

- bridge on your Mac
- Codex on your Mac
- relay as transport only
- iPhone as remote client

The relay does not run Codex and does not receive plaintext application payloads after the secure handshake completes.

## Option 1: Local Relay

This is useful for local testing. On macOS, it is now the default source-install path.

First install the CLI from source:

```sh
cd phodex-bridge
npm install
npm link
```

Then start the managed local relay + bridge service:

```sh
icodex up
```

That macOS command:

- starts a local relay on your Mac
- starts the bridge in the background
- prints the pairing QR code
- keeps running after you close the terminal

Useful follow-up commands:

```sh
icodex status
icodex stop
```

If the advertised LAN hostname should be different, override it:

```sh
ICODEX_LOCAL_RELAY_HOSTNAME="192.168.1.10" icodex up
```

If Tailscale is running, `icodex up` also advertises a Tailscale relay candidate in the QR payload so the phone can reconnect away from your LAN. To force a specific Tailscale hostname or address, set:

```sh
ICODEX_LOCAL_RELAY_TAILSCALE_HOST="100.x.y.z" icodex up
```

To disable that extra advertised relay candidate:

```sh
ICODEX_LOCAL_RELAY_INCLUDE_TAILSCALE=false icodex up
```

If you want to run the pieces manually instead, start the relay:

```sh
cd relay
npm install
npm start
```

Start the bridge in another terminal:

```sh
ICODEX_RELAY="ws://127.0.0.1:9000/relay" icodex up
```

Then:

1. open the iPhone app
2. scan the QR code
3. send a prompt

Health check:

```sh
curl http://127.0.0.1:9000/health
```

Expected response:

```json
{"ok":true}
```

## Option 2: Tailscale or Remote Self-Hosted Relay

This is the recommended path for regular iPhone use.

1. run the relay on a machine you control
2. put that machine on Tailscale, or expose it behind your own `wss://` endpoint
3. start the bridge with that relay URL
4. pair once with QR
5. reconnect through the same relay later

Example bridge launch:

```sh
ICODEX_RELAY="wss://relay.example.com/relay" icodex up
```

Compatibility note:

- `ICODEX_RELAY` is the preferred variable
- `REMODEX_RELAY` is still accepted as a fallback
- if you skip `npm link`, run the source binary directly with `cd phodex-bridge && node ./bin/icodex.js up`

## Reverse Proxy Notes

If you front the relay with Nginx, Caddy, or Traefik:

- forward WebSocket upgrades correctly
- preserve the `/relay/...` path expected by the Node relay
- use `wss://` for public internet exposure

## Push Notifications

Push is optional.

If you do not configure push:

- pairing still works
- chat transport still works
- local app usage still works

Only enable push if you also plan to manage APNs credentials and relay-side notification infrastructure yourself.

## Troubleshooting

### The iPhone cannot connect

Check:

- the relay is reachable from the phone
- the bridge is using the intended relay URL
- your proxy forwards WebSockets correctly
- the URL is `wss://` when crossing the public internet

### Pairing fails over plain LAN

Prefer Tailscale or another stable private network path instead of continuing to rely on raw same-Wi-Fi routing.

### The QR scans but reconnect later fails

Usually one of these is true:

- the relay URL changed
- the bridge was restarted against a different relay
- the trusted session on the relay is no longer valid

In that case, start the bridge again and scan a fresh QR code.
