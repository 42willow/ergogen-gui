{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
        system: function nixpkgs.legacyPackages.${system}
      );
  in {
    packages = forAllSystems (pkgs: {
      ergogen-gui = pkgs.callPackage ./package.nix {};
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.ergogen-gui;
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          libiconv
        ];

        nativeBuildInputs = with pkgs; [
          cargo-tauri
          nodejs
          yarn
          pkg-config
        ];

        RUSTFLAGS = "-L ${pkgs.libiconv}/lib";
        ERGOGEN_VERSION = "github:ceoloide/ergogen#v4.3.0";
      };
    });
  };
}
