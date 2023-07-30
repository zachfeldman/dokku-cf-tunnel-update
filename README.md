# dokku-cf-tunnel-update

Expose Dokku apps on a home server via Cloudflare tunnels by keeping their service IPs updated on app deployments and restarts.

WARNING: This plugin will erase any existing config you have of a tunnel, so be careful the first time you use it especially!

## Getting Started

- Install the plugin
- Set your credentials in .bashrc or equivalent: `CF_AUTH_EMAIL`, `CF_AUTH_KEY`, `CF_ACCOUNT_UUID`, and `CF_TUNNEL_UUID` and source it

## Specifying other tunnels besides Dokku apps

If you have other tunnels you want to persist between deploys, you can put a `.cf-tunnel-config` file at `/home/dokku` with them. There's a `.cf-tunnel-config-sample` in the repo you can refer to, but this basically gets injected into the CURL to the Cloudflare API when setting up your tunnel.