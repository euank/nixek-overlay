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
          self.overlay
        ];
        config = { allowUnfree = true; };
      };
    in {
      overlay =  (final: prev: rec {
        modules = {
          inspircd = import ./modules/inspircd;
          spigot-mc = import ./modules/spigot-mc;
          drone-server = import ./modules/drone-server;
          drone-docker-runner = import ./modules/drone-docker-runner;
        };

        hashpipe = final.callPackage ./pkgs/applications/networking/irc/hashpipe {};

        inspircd = final.callPackage ./pkgs/applications/networking/irc/inspircd {};

        inspircd2 = final.callPackage ./pkgs/applications/networking/irc/inspircd2 {};

        maptool = final.callPackage ./pkgs/games/maptool {
          openjdk14 = nixpkgs-20_09.outputs.legacyPackages.x86_64-linux.pkgs.openjdk14;
        };

        meslolgs-nf = final.callPackage ./pkgs/data/fonts/meslolgs-nf {};

        np2kai = final.callPackage ./pkgs/misc/emulators/np2kai {};

        spigot-mc = final.callPackage ./pkgs/games/spigot {};

        bukkit-plugins = final.callPackage ./pkgs/games/spigot/plugins.nix {};

        tl = final.callPackage ./pkgs/applications/security/tl {};

        terraform-providers = final.terraform-providers // {
          stripe = final.callPackage ./pkgs/applications/networking/cluster/terraform-providers/stripe {};
        };

        vivarium-unwrapped = final.callPackage ./pkgs/applications/window-managers/vivarium {};
        vivarium = final.callPackage ./pkgs/applications/window-managers/vivarium/wrapper.nix {};

        nixek-images = final.callPackage ./images { };
      });
      packages.x86_64-linux = pkgs;
    };
}
