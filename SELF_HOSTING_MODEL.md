# iCodex Self-Hosting Model

This fork is intentionally source-first and local-first.

## What this repo includes

- the iPhone app source
- the Mac bridge source
- the self-hostable relay source
- local pairing and self-hosting docs

## What this repo does not include

- a hosted default relay
- private publish-time package defaults
- private deployment runbooks
- App Store-specific hosted-service assumptions

## Supported operation

The supported production paths for this fork are:

1. self-host your own relay
2. reach that relay over Tailscale or another private network

Codex still runs on your Mac. The relay is only the transport layer.

## Important implications

- on macOS, `icodex up` can manage a local relay for you when no explicit relay URL is set
- external relay setups should still pass an explicit relay URL
- the iPhone app should be built from source for your own use
- public hosted domains should not be assumed anywhere in the repo
- docs should describe self-hosting and Tailscale, not a managed relay

## Current defaults

- preferred local macOS command after `npm link`: `icodex up`
- preferred external-relay command after `npm link`: `ICODEX_RELAY="..." icodex up`
- direct source bridge command without `npm link`: `cd phodex-bridge && node ./bin/icodex.js up`
- preferred relay env var: `ICODEX_RELAY`
- preferred local-relay hostname override: `ICODEX_LOCAL_RELAY_HOSTNAME`
- local bridge state directory: `~/.icodex`

`REMODEX_*` env vars remain accepted as compatibility fallbacks where needed, but this fork should document and prefer `ICODEX_*`.
