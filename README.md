# dokku-cf-tunnel-update

Expose Dokku apps on a home server via Cloudflare tunnels by keeping their service IPs updated on app deployments and restarts.

**WARNING: This plugin will erase any existing config you have of a tunnel, so be careful the first time you use it especially!**

## Getting Started

- Install Ruby on your server (tested with Ruby 3.0.2)
- Install the plugin `sudo dokku plugin:install https://github.com/zachfeldman/dokku-cf-tunnel-update`
- Set your credentials in .bashrc or equivalent: `CF_AUTH_TOKEN`, `CF_ACCOUNT_UUID`, and `CF_TUNNEL_UUID` and source it (`CF_AUTH_TOKEN` is a Cloudflare API Token with the `Account:Cloudflare Tunnel:Edit` permission). 
  - You may need to set them in both your home user and the Dokku user depending on your context of deployment or app restart.
 - Run an app deployment or restart
   - *On the first run, you may need to add a CNAME record pointing to your Cloudflare tunnel*, which is usually <tunnel_uuid>.cfargotunnel.com

## Specifying other tunnels besides Dokku apps

If you have other tunnels you want to persist between deploys, you can put a `.cf-tunnel-config` file at `/home/dokku` with them. There's a `.cf-tunnel-config-sample` in the repo you can refer to, but this basically gets injected into the request to the Cloudflare API when setting up your tunnel as an additional tunnel in the list.

## Caveats, Future Roadmap

This is a working plugin, but it has a few caveats and things not developed yet:
- HTTPS is only working from the browser to Cloudflare, not Cloudflare to the app.
  - LetsEncrypt plugin is not currently working with this set up
- There's no help command or other nice to haves for this plugin
- The core of the logic is implemented in Ruby, so it has to be installed in order to use the app - it was a bit hard to write more of it in `bash` easily. Perhaps this could be fixed in a future update, or it might be the right approach anyway.