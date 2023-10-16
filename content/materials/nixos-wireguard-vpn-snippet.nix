# CHANGE enp34s0
# CHANGE route IP address

# Route for wireguard VPN. Not sure why it's needed but without the route
# the system can not reach VPN server. We tell the network layer
# that this subnet could be reached through that gateway.
networking.interfaces.enp34s0.ipv4.routes = [{
  address = "18.19.33.66";
  prefixLength = 32;
  via = "192.168.0.1";
}];

# Restart network interface upon suspend (don't know how to make
# services restart by itself). We need to restart
# network-addresses-enp34s0 as it creates route specified above. After
# suspend dhcpcd flushes all routes. We need to add the route and
# restart our VPN tunnel (don't know why also).
systemd.services.suspend-restart = {
  wantedBy = [ "suspend.target" ];
  after = [ "suspend.target" ];
  description = "Restart network interface to initialize routes";
  serviceConfig = {
    Type = "simple";
    ExecStart = ''
                ${pkgs.systemd}/bin/systemctl --no-block restart \
                        network-addresses-enp34s0.service
    '';
  };
};

# Temporary fix for https://github.com/NixOS/nixpkgs/issues/162260
# The wait is necessary to let dhcpcd receive IP
systemd.services.network-addresses-enp34s0 = {
  after = [ "dhcpcd.service" ];
  preStart = "sleep 10\n";
};

# After suspend we restart network-addresses-enp34s0 service. We need to
# restart wireguard after that
systemd.services.wireguard-wg0 = {
  after = [ "network-addresses-enp34s0.service" ];
  requires = [ "network-addresses-enp34s0.service" ];
};

