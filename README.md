# Ruby TUI for Mullvad VPN

This is a Terminal App I wrote for myself to use with Mullvad VPN on Linux. It makes it easier for me to choose servers when using Mullvad from the command line.

![mullvad](https://github.com/user-attachments/assets/1c628381-9a7c-40f4-9376-2f65496b2bc8)

The app has two "backends", [Mullvad CLI](https://mullvad.net/en/help/how-use-mullvad-cli) or [WireGuard](https://mullvad.net/en/help/wireguard-and-mullvad-vpn).

Most of the basic functionality is available for either backend: Select a server (random, by country, specific server), connect, disconnect and show the current status. You can use either backend. The first time you run the app, it's going to ask you which one you want to use, and save your preference in `~/.local/share/mullvadrb/backend.conf`. You can switch backends from the Main Menu on the app at any time.

## Requirements

You need to have a [Mullvad VPN](https://mullvad.net) account to use the app.

> [!WARNING]
> `mullvad` uses WireGuard, so if you change backends while connected to an OpenVPN server with `wg`, `mullvad` won't be able to disconnect from the OpenVPN connection.
> In general, it's a good idea to stick to one backend, and disconnect from the VPN before switching backends.
> This might potentially be fixed in the future.

### For the WireGuard backend

You need to [install WireGuard](https://www.wireguard.com/install/) and follow the instructions on [Mullvad: WireGuard on Linux terminal](https://mullvad.net/en/help/wireguard-and-mullvad-vpn). The configuration script you are asked to run in this last link will download the WireGuard configuration files needed to `/etc/wireguard`.

The app is basically a layer on top of `wg-quick`. The scripts it runs are:
```
$ wg-quick up <connected server (e.g. uy-mma-wg-001)> # Connect with WireGuard
$ curl https://am.i.mullvad.net/connected # Check if you're connected to Mullvad
$ wg-quick down <connected server> # Disconnect
```
It uses `sudo` to read the files on `/etc/wireguard` and execute `wg-quick` for connecting and disconnecting.

### For the Mullvad CLI backend

You need to install [the Mullvad CLI](https://mullvad.net/en/download/vpn/linux) to use this backend.

On first run, you need to log in (unless you've already run `mullvad account login` on your terminal before). The servers list will be updated and will be saved to `~/.local/share/mullvadrb.dump`.

## Development

Run gem from the source:

```bash
$ irb -Ilib -rmullvadrb
```
