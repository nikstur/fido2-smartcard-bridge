let
  sources = import ./lon.nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  packages = [
    pkgs.lon
    pkgs.ruff
    pkgs.ty
  ];

  inputsFrom = [
    (import ./.)
  ];

  shellHook = ''
    ${(import ./nix/pre-commit.nix { inherit pkgs; }).shellHook}
  '';
}
