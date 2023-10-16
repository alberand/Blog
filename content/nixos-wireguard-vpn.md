Title: NixOS Wireguard VPN setup
Date: 12.11.2023
Modified: 12.11.2023
Status: published
Tags: pelican, publishing
Keywords: pelican, publishing
Slug: nixos-wireguard-vpn
Author: Andrey Albershtein
Summary: Let's configure wireguard VPN on NixOS with a kill-switch
Lang: en

Recently I finally decided to configure VPN for my main machine. My choice fell
on Mullvad VPN which is amazing. They don't even need your email for an account
(first time seeing this :D).

This guide is for configuring Wireguard tunnel using Mullvad VPN servers, but
you can apply this configuration to any Wireguard VPN.

The [NixOS wiki][1] shows starting ground for running Wireguard tunnel. The wiki
shows multiple example with `networking.wireguard`, `networking.wg-quick` and
`systemd-networkd` for both server and client. Moreover you can find
[mullvad-vpn app][2] and configure VPN through the clean GUI, but it will not be
declarative (not in your `configuration.nix`.

I **recommend** going with `networking.wg-quick` as it's probably the easiest one.

First of all, let's create a separate file, so it won't be a problem in the
future to use this module on another machine.

```nix
# modules/wireguard.nix
{ pkgs, ... }: {
}
```

Don't forget to add this file to the `imports` list in the `configuration.nix`:

```nix
{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./modules/wireguard.nix
  ];
  ...
}
```

In that file copy-paste the same configuration suggested in wiki's "Client"
section:

```nix
{ pkgs, ... }: {
  networking.wg-quick.interfaces = let
    server_ip = "18.19.23.66";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.64.186.60/32"
        "fdc9:281f:04d7:9ee9::2/64"
      ];

      # To match firewall allowedUDPPorts (without this wg
      # uses random port numbers).
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/etc/mullvad-vpn.key";

      peers = [{
        publicKey = "1493vtFUbIfSpQKRBki/1d0YgWIQwMV4AQAvGxjCNVM=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "${server_ip}:51820";
        persistentKeepalive = 25;
      }];
    };
  };
}
```
On Mullvad website go to "WireGuard configuration" in the left sidebar. Pick
country, server, port and any content blockers you wish, enable killswitch
checkbox. Download `*.conf` file, mine is `dk-cph-wg-401.conf`.

```ini
[Interface]
# Device: Fast Basset
PrivateKey = SL/xaxaFRogeNoDOOontGolvdIJ5x8mgLw0U/+1McG4=
Address = 10.75.130.74/32,fc00:bbbb:bbbb:bb01::4:be49/128
DNS = 100.64.0.3
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

[Peer]
PublicKey = Jjml2TSqKlgzW6UzPiJszaun743QYpyl5jQk8UOQYg0=
AllowedIPs = 0.0.0.0/0,::0/0
Endpoint = 146.70.197.194:51820
```

# Private VPN configuration files

We can not put Mullvad VPN configuration file to the Nix configuration directly.
The `dk-cph-wg-401.conf` contains private key which should not be shared.
`/nix/store` is world readable, by putting this file in the `*.nix` any user
would be able to read your private key.

Let's put private key to the `/etc/mullvad-vpn.key`:

```shell
cat dk-cph-wg-401.conf | grep "PrivateKey" | awk '{ print $3 }' | \
    sudo tee /etc/mullvad-vpn.key
```

Let's make it readable only by the owner (root):

```shell
sudo chmod 400 /etc/mullvad-vpn.key
```

# Copy configuration from `dk-cph-wg-401.conf` to `modules/wireguard.nix`

Now you need to copy values from Mullvad config to Nix configuration so it's
declarative. Each parameter has a line above it, which describes corresponding
item inf Mullvad's `dk-cph-wg-401.conf` file.

```nix
{ pkgs, ... }: {
  networking.wireguard.interfaces = let
    # [Peer] section -> Endpoint
    server_ip = "18.19.23.66";
  in {
    wg0 = {
      # [Interface] section -> Address
      ips = [ "10.75.130.74/32" ];

      # [Peer] section -> Endpoint:port
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/etc/mullvad-vpn.key";

      peers = [{
        # [Peer] section -> PublicKey
        publicKey = "1493vtFUbIfSpQKRBki/1d0YgWIQwMV4AQAvGxjCNVM=";
        # [Peer] section -> AllowedIPs
        allowedIPs = [ "0.0.0.0/0" ];
        # [Peer] section -> Endpoint:port
        endpoint = "${server_ip}:51820";
        persistentKeepalive = 25;
      }];
    };
  };
}
```

Now, that's enough to have a VPN tunnel. But, to be on a safe side you need a
killswitch. The killswitch is networking filter which will allow traffic go only
through VPN. So, when VPN tunnel suddenly goes down you won't expose your real
IP address.

# Killswitch! All traffic through VPN

If you enabled killswitch checkbox on Mullvad's configuration page, then, your
*.conf file will have `PostUp` and `PreDown` fields. These are shell commands
run before and after VPN is started.

```ini
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
```
In my config, Wireguard runs `iptables` to tell network stack that any packet
which goes not through wg0 interface should be REJECTed. `iptables` is utility
used to create network filters. Now copy those rules to the `postUp` and
`postDown` parametrs in `modules/wireguard.nix`.

```nix
postUp = ''
  # Mark packets on the wg0 interface
  wg set wg0 fwmark 51820

  # Forbid anything else which doesn't go through wireguard VPN on
  # ipV4 and ipV6
  ${pkgs.iptables}/bin/iptables -A OUTPUT \
    ! -d 192.168.0.0/16 \
    ! -o wg0 \
    -m mark ! --mark $(wg show wg0 fwmark) \
    -m addrtype ! --dst-type LOCAL \
    -j REJECT
  ${pkgs.iptables}/bin/ip6tables -A OUTPUT \
    ! -o wg0 \
    -m mark ! --mark $(wg show wg0 fwmark) \
    -m addrtype ! --dst-type LOCAL \
    -j REJECT
'';
```

Note that Nix configuration has a few differences:

- a full path to any utility `${pkgs.iptables}/bin/iptables` instead of just
  `iptables`.
- to mark all network packets going through wg0 interface `wg set wg0 fwmark
  51820` command is needed. This is probably necessary to not create a closed
  loop in the filter.
- Wireguard interface is directly specified as `wg0`. Nix module does not
  currently pass any parameters to those commands, general `%i` replacement can
  not be used

Same for `PreDown` -> `postDown` conversion:

```nix
postDown = ''
  ${pkgs.iptables}/bin/iptables -D OUTPUT \
    ! -o wg0 \
    -m mark ! --mark $(wg show wg0 fwmark) \
    -m addrtype ! --dst-type LOCAL \
    -j REJECT
  ${pkgs.iptables}/bin/ip6tables -D OUTPUT \
    ! -o wg0 -m mark \
    ! --mark $(wg show wg0 fwmark) \
    -m addrtype ! --dst-type LOCAL \
    -j REJECT
'';
```

# Exclude traffic/port/IP from VPN

Local network application don't need VPN. We can exclude particular IP
addresses or ports. For example to exclude `kdeconnect` ports (range 1714-1764
for UDP and TCP) from VPN add following `iptables` rules into `postSetup`:

```nix
# Accept kdeconnect connections
${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p udp \
    --dport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p tcp \
    --dport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -A OUTPUT -o wg0 -p udp \
    --sport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -A OUTPUT -o wg0 -p tcp \
    --sport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
```

To exclude local port (in this case Deluge web client is running in container on
port 8112):

```nix
# Allow deluge web gui
${pkgs.iptables}/bin/iptables -I OUTPUT -o lo -p tcp \
    --dport 8112 -m state --state NEW,ESTABLISHED -j ACCEPT
```

Another example is to exclude subnet for Nix containers (container has IP of
10.233.1.2 and host 10.233.1.1):

```nix
${pkgs.iptables}/bin/iptables -I OUTPUT -s 10.233.1.0/24 -d 10.233.1.0/24 \
    -j ACCEPT
```

# I want to use `networking.wireguard`

This was my initial approach and there's two additional things to handle:

## Additional IP route

As configuration specifies `allowedIPs = 0.0.0.0/0` all connection on `wg0`
interface will be routed through VPN tunnel. This creates a routing issue as
Wireguard needs to connect to endpoint via public network.

To do so, create a new route to tell network stack to route traffic going to
endpoint IP (18.19.23..) through main gateway (192.168.0.1 is my WiFi router):

```nix
networking.dhcpcd.runHook = ''
  ${pkgs.iproute2}/bin/ip route add 18.19.23.66/32 via 192.168.0.1 dev enp34s0
'';
```

You can create the route with `networking.interfaces` but it will not work just
like that! The route will be flushed on suspend.

```nix
networking.interfaces.enp34s0.ipv4.routes = [{
    address = "18.19.23.66";
    prefixLength = 32;
    via = "192.168.0.1";
}];
```

## Wireguard VPN doesn't work after suspend/sleep

Unfortunately, `dhcpcd` will not re-create an additional route created via
`networking.interfaces`. There is similar problem described at [Arch Wiki][4],
but I don't use `systemd-networkd` so that doesn't apply.

On my system `dhcpcd.service` creates all necessary IP routes. But the one
necessary for Wireguard is created by `network-addresses-enp34s0.service`. This
service doesn't restart after suspend. As `dhcpcd` will remove all routes on
wake-up, Wireguard will fail to connect to the endpoint.

Note that by using `networking.dhcpcd.runHook` this problem is solved as route
is created by `dhcpcd` itself.

To make it work without `dhcpcd` hook, I decided to go with easy fix by
restarting the VPN service after network is established. To do so:

- add a services for restarting address obtaining for network interface,
- then make it sleep a little (waiting for dhcpcd set things up),
- and make Wireguard service dependable on this all.

See [this code snippet][5] for doing this in code.

The `suspend-restart` also creates route as described in [Additional IP
route](#additional-ip-route). This is not a nice way to solve it but I didn't
want to continue with this solution as I switched to `wg-quick` which doesn't
need all of this. This is probably the same problem as described in Arch Wiki,
so, if you know how to fix it send me a message, I will update the article.

# References

- [NixOS Wiki Wireguard][1]
- [Mullvad-vpn application in Nix repo][2]
- [Wireguard AllowIPs Calculator][3]
- [Arch Wiki - Connection lost after sleep][4]

[1]: https://nixos.wiki/wiki/WireGuard
[2]: https://search.nixos.org/packages?show=mullvad-vpn&type=packages&query=mullvad
[3]: https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/
[4]: https://wiki.archlinux.org/title/WireGuard#Connection_lost_after_sleep_using_systemd-networkd
[5]: /materials/nixos-wireguard-vpn-snippet.nix
