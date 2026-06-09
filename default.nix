{
  sources ? import ./lon.nix,
  pkgs ? import sources.nixpkgs { },
}:

rec {
  nixosModules.fido2-smartcard-bridge =
    { lib, ... }:
    {
      imports = [ ./nix/module.nix ];
      services.fido2-smartcard-bridge.package = lib.mkDefault packages.fido2-smartcard-bridge;
    };

  packages.fido2-smartcard-bridge = pkgs.callPackage ./nix/package.nix { };
}
