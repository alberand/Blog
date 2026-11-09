Title: How to run an application in container on NixOS
Date: 18.06.2025
Modified: 18.06.2025
Status: draft
Tags: nixos, nspawn, container, homelab
Slug: how-to-run-application-in-container
Author: Andrej
Summary: Containers are an easy way to secure and isolate application running on
your server.
Lang: en

Containers are an easy way to secure and isolate application running on
your server. I put most of apps running on my server into containers. Even
though most of those apps are behind VPN, some of them are exposed to wider
internet. Any vulnerability in these could lead to access to my private network.

On NixOS, there's two big options how to run application in containers:

- *The classic* OCI containers such as Podman/Docker
- *systemd-nspawn* - systemd containers created mainly for development purposes
  in mind

Why to use systemd-nspawn then? There's two things.

The host shares /nix/store with the `nspawn` container, this means that spinning
up the container doesn't require any image. The guest is also NixOS.

Secondly, as guest is NixOS we can easily declare guest system with Nix. We can
use all the packages, services, and options provided by NixOS. This is hugely
simplifies the process of creating containers.

# Security

According to [main maintainer of systemd][1] `systemd-nspawn` was created for
development purposes and should not be used for deployments. Although this is
true, `nspawn` is still pretty secure and is sooo convenient on NixOS.

These containers are *privileged* by default (root inside is root outside).

TODO describe user isolation, capabilities, unprivileged mode

Unprivileged mode is not possible in the default NixOS configuration as systemd
doesn't support `--directory` argument in unprivileged mode. We will need to
create an image or tarball to use it with `--image`. Like described [here][2].

Summing up, I think systemd-nspawn is good enough for running services for your
homelab, especially if they are not exposed to wider internet. With precaution
such as running services under non-root users inside the container, dropping all
the possible capabilities, and isolating network interfaces I don't see any high
risk threats.

# Container

In this post I will show how to host [Forgejo][5] instance. Initial setup is
pretty simple, somewhere in your `configuration.nix` add the following:

```nix
  containers.forgejo = {
    autoStart = true;
    ephemeral = true;
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = [
        busybox
        vim
      ];

      system.stateVersion = "25.05";

      networking = {
        firewall = {
          enable = true;
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;
    };
  };
```

This will create an empty container named "forgejo". Run `machinectl list` to
see if it's there.

This container autostart with the system and is ephemeral, which means it will
not leave any trace after itself in the filesystem (guest will have a snapshot
of the filesystem).

The `ephemeral = true;` is not necessary at all but it nice to have if you want
to get closer to the stateless containers.

# Network

For single container define private network:

```diff
 containers.forgejo = {
   autoStart = true;
   ephemeral = true;
+  privateNetwork = true;
+  hostAddress = "10.10.10.100";
+  localAddress = "10.10.10.40";
   config = {
     config,
     pkgs,
```

The `privateNetwork = true;` isolates guest network stack from the host's one.
If not set your guest will have access to all network interfaces your host has.
The output of `ip a` will be the same for both.

With private network, nspawn will create a virtual network interface. One end of
this interface will be on the host, with IP `hostAddress = "10.10.10.100";`, and
the other in the guest, with IP `localAddress = "10.10.10.40";`.

Now, ping should work both ways.

For multiple containers you will need a network bridge. I prefer using
systemd-networkd for this.

First thing first let's enable `networkd` and create a bridge:

```diff
+systemd.network.enable = true;
+systemd.network.wait-online.enable = false;
+# Need to be removed if NetworkManager is not used
+networking.useNetworkd = true;
+
+systemd.network = {
+  netdevs."cbr" = {
+    netdevConfig = {
+      Name = "cbr";
+      Kind = "bridge";
+    };
+  };
+};
+
 containers.forgejo = {
   autoStart = true;
   ephemeral = true;
   config = {
     config,
     pkgs,
```

Then we need to configure network for this bridge, meaning assign some IP
address, set gateway and a route for other network nodes.

```diff
@@ -10,6 +10,24 @@ systemd.network = {
       Kind = "bridge";
     };
   };
+
+  networks = {
+    # Assign IP to host end of a bridge (although I suppose all ends of the
+    # bridge are on the host side of things)
+    "20-br0-uplink" = {
+      matchConfig.Name = "cbr";
+      networkConfig = {
+        Address = "10.10.10.100/24";
+      };
+      routes = [
+        {
+          Gateway = "10.10.10.100";
+          Source = "10.10.10.0/24";
+          Destination = "10.10.10.0/24";
+        }
+      ];
+    };
+  };
 };

 containers.forgejo = {
```

Finally, add a container to the network:

```diff
@@ -15,6 +15,10 @@ systemd.network = {
 containers.forgejo = {
   autoStart = true;
   ephemeral = true;
+  privateNetwork = true;
+  hostBridge = "cbr";
+  localAddress = "10.10.10.40/24";
   config = {
     config,
     pkgs,
```

The `hostBridge = "cbr";` is the key, it adds host's side of virtual ethernet
link to the `cbr` bridge create by networkd.

# Sharing directories

Sharing directories is pretty straightforward:

```diff
@@ -44,6 +44,16 @@ containers.forgejo = {
   privateNetwork = true;
   hostBridge = "cbr";
   localAddress = "10.10.10.40/24";
+  bindMounts = {
+    "/storage" = {
+      hostPath = "/storage";
+      isReadOnly = false;
+    };
+    "/var/lib/forgejo" = {
+      hostPath = "/storage/var/lib/forgejo";
+      isReadOnly = false;
+    };
+  };
   config = {
     config,
     pkgs,
```

This maps two directories `/storage` on the host to `/storage` on the guest and
`/storage/var/lib/forgejo` on the host to `/var/lib/forgejo` on the guest.

With stateless containers we can store Forgejo configuration on the host and
just pass it to the container.

On the host, this directories should have all necessary permission for the guest
user to be able to access it. On NixOS directory creating can be declared with
`systemd.tmpfiles`.

```diff
@@ -38,6 +38,21 @@ systemd.network = {
   };
 };

+users.users.forgejo = {
+  isNormalUser = true;
+  uid = 3000;
+  group = "forgejo";
+};
+
+users.groups.forgejo = {
+  gid = 3000;
+};
+
+systemd.tmpfiles.rules = [
+  "d /storage 700 forgejo forgejo -"
+  "d /storage/var/lib/forgejo 700 forgejo forgejo -"
+];
+
 containers.forgejo = {
   autoStart = true;
   ephemeral = true;
```

Note, that we also need to create a user with a UID/GID on the host. The same
should be done in container.

```diff
@@ -80,6 +80,9 @@ containers.forgejo = {
       vim
     ];

+    users.users.forgejo.uid = 3000;
+    users.groups.forgejo.gid = 3000;
+
     system.stateVersion = "25.05";

     networking = {
```

# Port Forwarding

For port forwarding use:

```diff
@@ -69,6 +69,13 @@ containers.forgejo = {
       isReadOnly = false;
     };
   };
+  forwardPorts = [
+    {
+      containerPort = 2222;
+      hostPort = 3333;
+      protocol = "tcp";
+    }
+  ];
   config = {
     config,
     pkgs,
```

This will open port 3333 on the host and forward traffic to the port 2222 on
container. 

I prefer to use `nftables`, as this way I can have more flexible setup:

```diff
@@ -53,6 +53,20 @@ systemd.tmpfiles.rules = [
   "d /storage/var/lib/forgejo 700 forgejo forgejo -"
 ];
 
+networking = {
+  nftables = {
+    enable = true;
+    ruleset = ''
+      table ip nat {
+        chain PREROUTING {
+          type nat hook prerouting priority dstnat; policy accept;
+          iifname "eth1" tcp dport 3333 dnat to 10.10.10.40:2222
+        }
+      }
+    '';
+  };
+};
+
 containers.forgejo = {
   autoStart = true;
   ephemeral = true;
```

If you're using firewall don't forget to open these ports

```diff
@@ -54,6 +54,9 @@ systemd.tmpfiles.rules = [
 ];

 networking = {
+  firewall.allowedTCPPorts = [
+    3333
+  ];
   nftables = {
     enable = true;
     ruleset = ''
@@ -109,6 +112,9 @@ containers.forgejo = {
     networking = {
       firewall = {
         enable = true;
+        allowedTCPPorts = [
+          2222
+        ];
       };
       # Use systemd-resolved inside the container
       # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
```

# Bonus points

## Rootless containers

Running nspawn container without root would be really nice improvement to
security of the host system, but this requires creating disk image of the guest
system first. In [this repository][2], you can find how to achieve it.

But to run nspawn with an image instead of directory tree will also require
modification to NixOS's `containers.` implementation as it doesn't currently
support `--image` argument.

Sorry, no solution here for now :<

## Sharing GPU

Jellyfin/Plex container will need access to GPU for transcoding.

Device virtualization is not supported by linux kernel. That means that we can
not make few virtual isolated copies of the device. Therefore, passing GPU to a
container basically is not that different then using it outside of the
container.

Citing systemd maintainer it's ["awful hack"][6] but it works:

```diff
```

1: https://lwn.net/Articles/572957/
2: https://github.com/tfc/nspawn-nixos/tree/main
3: https://people.kernel.org/brauner/runtimes-and-the-curse-of-the-privileged-container
4: https://opensource.com/business/14/7/docker-security-selinux
5: https://forgejo.org/
6: https://github.com/systemd/systemd/issues/10960
