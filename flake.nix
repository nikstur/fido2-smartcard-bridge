{
  description = "FIDO2 SmartCard Bridge";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      nixosModules = {
        default = (
          { pkgs, lib, ... }:
          {
            imports = [
              ./nix/module.nix
            ];

            services.fido2-smartcard-bridge.package =
              let
                system = pkgs.stdenv.hostPlatform.system;
              in
              lib.mkDefault self.packages.${system}.default;
          }
        );
      };

      packages = eachSystem (system: {
        default =
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          pkgs.callPackage ./nix/package.nix { };
      });
    };
}
