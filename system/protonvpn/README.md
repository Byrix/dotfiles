# ProtonVPN Dotfiles 
## Packages
Package lists provided in `./pkglist.txt` and `./pkglist_opt.txt` for required and optional packages respectively. Dependencies not listed there or here. 

### Required
- `openvpn`

### Optional
Note that for tray icon to work both packages must be installed. 

- `libappindicator-gtk3` for tray icon
- `gnome-shell-extension-appindicator` for tray icon

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
3. Create a `/etc/openvpn/client/login.conf` file with the username and password using the *OpenVPN / IKEv2 Username* from the (https://account.protonvpn.com/account)[ProtonVPN accounts page]. 
