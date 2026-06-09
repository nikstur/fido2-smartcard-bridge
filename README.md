# FIDO2 SmartCard Bridge

Browsers on Linux do not support FIDO2 SmartCards. They only support the now
ubiquitous USB tokens.

However, there are some really cool FIDO2 SmartCards around, like the one
from [Token2](https://www.token2.com/shop/product/t2f2-nfc-card-pin-release39).

This bridge allows you to use your FIDO2 SmartCards as authenticators in your
browser.

It works by presenting a HID device to the operating system which the broswer
can talk to as if it was a USB FIDO2 token. The commands the browser sends to
this HID device are then proxied to the SmartCard.

This uses the kernel's [UHID subsystem](https://docs.kernel.org/hid/uhid.html)
to create a HID device and pcscd to speak to the SmartCard.

## Usage

You basically just need to enable the service. However, you it's currently not
in Nixpkgs (thus please read on!).

```nix
services.fido2-smartcard-bridge.enable = true;
```

### [Lon](github.com/nikstur/lon)

Add `fido2-smartcard-bridge` as a dependency via lon:

```console
$ lon add github nikstur/fido2-smartcard-bridge
Adding fido2-smartcard-bridge...
Locked hash: sha256-lf6vQ+KvxKs3ARBO9G3l+4wFbbCYtRBrwX1g+I+B61wQ=
```

```nix
# file: configuration.nix
{ pkgs, lib, ... }:
let
  sources = import ./lon.nix;
  fido2-smartcard-bridge = import sources.fido2-smartcard-bridge {
    inherit pkgs;
  };
in
{
  imports = [ fido2-smartcard-bridge.nixosModules.default ];

  services.fido2-smartcard-bridge.enable = true;
}

```

### Flakes

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    fido2-smartcard-bridge = {
      url = "github:nikstur/fido2-smartcard-bridge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, fido2-smartcard-bridge, ...}: {
    nixosConfigurations.yourHost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        fido2-smartcard-bridge.nixosModules.default
        ({
          services.fido2-smartcard-bridge.enable = true;
        })
      ];
    };
  };
}
```

## Security & Sandboxing

This service is heavily sandboxed via systemd's built-in sandboxing. It is run
unprivileged (via `DynamicUser=true`), has no network access, and has only
access to /dev/uhid. Access to PC/SC devices is granted via a polkit rule.

You can check out all the applied sandboxing with:

```sh
systemd-analyze security fido2-smartcard-bridge
```

## Credit

- Most of the core code (and thus the underlying idea!) comes from Bryan
  Jacob's [fido2-hid-bridge](https://github.com/BryanJacobs/fido2-hid-bridge).
- [python-uhid](https://github.com/FFY00/python-uhid), the library used to
  create HID devices via Linux's uhid subsystem, is vendored in-tree.
