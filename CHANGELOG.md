# 0.0.9

- Refactors server update, removes OpenVPN options. OpenVPN support is being removed on January 15th, 2026: https://mullvad.net/en/blog/final-reminder-for-openvpn-removal
- Refactors country code, fixes an issue with space in names.
- Tested on Ruby 4.0.0 👍

# 0.0.8

- Better status format and message for blocked connection.
- Adds allowing LAN access through mullvad-cli.

# 0.0.7

- Fixes settings configuration, updates Settings code.

# 0.0.6

- Adds DNS Blockers functionality.
- Refactors settings into `Mullvadrb::Settings` module.

# 0.0.5

- Updates display for menu, adds separation between main functionality and settings.
- Sets the process name to 'mullvadrb'

# 0.0.4

Adds support for internationalization, translations can be added easily now. ¡Disponible en Español! The configuration file `backend.conf` has been replaced by `mullvadrb.yml` which will store the backend and locale preferences.

# 0.0.3

Minor cleanup in the code and updates the way status is displayed.

# 0.0.2

I added back the support for WireGuard, in cases you don't want to or can't install the `mullvad` cli app, which was the initial reason I built this. The first time you run the app, it's going to ask you which one you want to use, and save your preference in `~/.local/share/mullvadrb/backend.conf`. You can switch backends from the Main Menu on the app at any time.

- Added extra options on the Main Menu.
- Refactored the whole code.

# 0.0.1

Initial release. Allows you to use the TUI as an interface for mullvad, the Mullvad VPN CLI.

I  started this script as a test to build a TUI for Mullvad using WireGuard. Then I switched it to use the `mullvad` CLI. It called the command via a menu on the Terminal, allowing to access most (for now) of the CLI app's features.
