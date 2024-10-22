# Ruby TUI for Mullvad VPN

This is a Terminal App I wrote for myself to use with Mullvad VPN on Linux. It adds a Ruby terminal interface to [Mullvad CLI](https://mullvad.net/en/help/how-use-mullvad-cli). 

![mullvad](https://github.com/user-attachments/assets/1c628381-9a7c-40f4-9376-2f65496b2bc8)



On first run, you need to log in (unless you've already run `mullvad account login` on your terminal before). The servers list will be updated and will be serialized to `~/.local/share/mullvadrb.dump`.


## Requirements

You need to have a [Mullvad VPN](https://mullvad.net) account and install [the CLI](https://mullvad.net/en/download/vpn/linux).

## Development

Run gem from the source:

```bash
$ irb -Ilib -rmullvadrb
```

