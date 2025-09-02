# ProtonVPN Dotfiles 
## Packages
Package lists provided in `./pkglist.txt` and `./pkglist_opt.txt` for required and optional packages respectively. Dependencies not listed there or here. 

### Required
- `extra/openvpn`
- `aur/openvpn-update-systemd-resolved`

### Optional
Note that for tray icon to work both packages must be installed. 

- `local/libappindicator-gtk3` for tray icon
- `extra/gnome-shell-extension-appindicator` for tray icon

## Installation
For a full guide use the (https://wiki.archlinux.org/title/ProtonVPN)[ArchWiki page on ProtonVPN]. 

1. Requires a modified `*.ovpn` file from (https://account.protonvpn.com/downloads)[the ProtonVPN downloads page], stored in `/etc/openvpn/client`. 
2. To the above file append the following:
```conf
client
remote example.com 1194 udp 

auth-user-pass login.conf

script-security 2
setenv PATH /usr/bin 
up /usr/bin/update-systemd-resolved
down /usr/bin/update-systemd-resolved 
down-pre

dhcp-option DOMAIN-ROUTE .
```
3. Create a `/etc/openvpn/client/login.conf` file with the username and password using the *OpenVPN / IKEv2 Username* from the (https://account.protonvpn.com/account)[ProtonVPN accounts page] (new line separated). 
    a. Additionally, specificy `(username)+(options)` for additional config. `+f1` for anti-malware filtering, `+f2` for anti-malware and ad-blocking filtering, `+nr` for moderate NAT (can combine `nr` with previous options). 
4. Ensure `systemd-resolved.service` is enabled and running
5. Start/enable `protonvpn@(config-file).ovpn.service` where `(config-file)` is the name of the downloaded `ovpn` file.
