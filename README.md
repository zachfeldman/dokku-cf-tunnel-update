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

## Ensuring IPs are correct on system restart

You'll need to install the systemd service in this repository by copying the `dokku-ps-restart-cf-tunnel-update.service` file to `/etc/systemd/system` .

Then you'll have to set your credentials by running `sudo systemctl edit dokku-ps-restart-cf-tunnel-update.service`, which will bring up a screen similar to this where you can bring up your credentials:

```
### Editing /etc/systemd/system/dokku-ps-restart-cf-tunnel-update.service.d/override.conf
### Anything between here and the comment below will become the new contents of the file

[Service]
Environment="CF_ACCOUNT_UUID=<your-account-uuid>"
Environment="CF_TUNNEL_UUID=<your-account-uuid>"
Environment="CF_AUTH_TOKEN=<your-auth-token"

### Lines below this comment will be discarded

### /etc/systemd/system/dokku-ps-restart-cf-tunnel-update.service
# [Unit]
# Description=Dokku app ps restart to ensure Cloudflare IPs are accurate
# Requires=dokku-redeploy.service
# After=dokku-redeploy.service
# 
# [Service]
# Type=oneshot
# User=dokku
# ExecStart=/usr/bin/dokku ps:restart --all
# 
# [Install]
# WantedBy=docker.service

```

Reload the systemctl-daemon settings using:
`sudo systemctl daemon-reload`

Then try running the service with:
`sudo systemctl start dokku-ps-restart-cf-tunnel-update`

Then ensure it runs on start up with:
`sudo systemctl enable dokku-ps-restart-cf-tunnel-update.service`

## Specifying other tunnels besides Dokku apps

If you have other tunnels you want to persist between deploys, you can put a `.cf-tunnel-config` file at `/home/dokku` with them. There's a `.cf-tunnel-config-sample` in the repo you can refer to, but this basically gets injected into the request to the Cloudflare API when setting up your tunnel as an additional tunnel in the list.

## Caveats, Future Roadmap

This is a working plugin, but it has a few caveats and things not developed yet:
- HTTPS is only working from the browser to Cloudflare, not Cloudflare to the app.
  - LetsEncrypt plugin is not currently working with this set up
- There's no help command or other nice to haves for this plugin
- The core of the logic is implemented in Ruby, so it has to be installed in order to use the app - it was a bit hard to write more of it in `bash` easily. Perhaps this could be fixed in a future update, or it might be the right approach anyway.