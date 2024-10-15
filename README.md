# Ruby TUI for Mullvad VPN

This is a Terminal App I wrote for myself to use WireGuard with Mullvad VPN on Linux.

![mullvad-ruby](https://github.com/user-attachments/assets/cc2f7c0a-8325-44bb-9752-8c3a5495dba7)

It's basically a layer on top of `wg-quick`. The scripts this app runs are:

```
$ wg-quick up <connected server (e.g. uy-mma-wg-001)> # Connect with WireGuard
$ curl https://am.i.mullvad.net/connected # Check if you're connected to Mullvad
$ wg-quick down <connected server> # Disconnect
```

It runs `sudo` to read the files on `/etc/wireguard` and `wg-quick`.

## Requirements

You need to have a [Mullvad VPN](https://mullvad.net) account and [WireGuard](https://www.wireguard.com/install/), and need to have followed the instructions on [Mullvad: WireGuard on Linux terminal](https://mullvad.net/en/help/wireguard-and-mullvad-vpn). The configuration script you need to run from this last link will download the WireGuard configuration files needed into `/etc/wireguard`.
