# 0.0.2

I added back the support for WireGuard, in cases you don't want to or can't install the `mullvad` cli app, which was the initial reason I built this. The first time you run the app, it's going to ask you which one you want to use, and save your preference in `~/.local/share/mullvadrb/backend.conf`. You can switch backends from the Main Menu on the app at any time.

- Added extra options on the Main Menu.
- Refactored the whole code.

# 0.0.1

Initial release. Allows you to use the TUI as an interface for mullvad, the Mullvad VPN CLI.

I  started this script as a test to build a TUI for Mullvad using WireGuard. Then I switched it to use the `mullvad` CLI. It called the command via a menu on the Terminal, allowing to access most (for now) of the CLI app's features.
