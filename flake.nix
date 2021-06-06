{
  description = "my overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-20_09.url = "github:NixOs/nixpkgs/5622b6b6feb669edc227aaf000413d5b593d4051";
  };

  outputs = { self, nixpkgs, nixpkgs-20_09 }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          (final: prev: {
            openjdk14 = nixpkgs-20_09.outputs.legacyPackages.x86_64-linux.pkgs.openjdk14;
          })
          self.overlay
        ];
        config = { allowUnfree = true; };
      };
    in {
      overlay = import ./default.nix;
      packages.x86_64-linux = pkgs;
    };
}
