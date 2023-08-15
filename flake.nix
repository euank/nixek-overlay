{
  description = "my overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
        ];
        config = { allowUnfree = true; };
      };
    in {
      overlays.default =  (final: prev: {
        modules = {
          inspircd = import ./modules/inspircd;
        };

        coldsnap = final.callPackage ./pkgs/tools/virtualization/coldsnap {};

        nixos-ami-upload = final.callPackage ./pkgs/tools/virtualization/nixos-ami-upload {};

        hashpipe = final.callPackage ./pkgs/applications/networking/irc/hashpipe {};

        inspircd = final.callPackage ./pkgs/applications/networking/irc/inspircd {};

        inspircd2 = final.callPackage ./pkgs/applications/networking/irc/inspircd2 {};

        meslolgs-nf = final.callPackage ./pkgs/data/fonts/meslolgs-nf {};

        np2kai = final.callPackage ./pkgs/misc/emulators/np2kai {};

        sl = final.callPackage ./pkgs/tools/misc/sl {};

        nixek-images = final.callPackage ./images { };

        amis = final.callPackage ./amis { inherit nixpkgs; };
      });
      legacyPackages.x86_64-linux = pkgs.pkgs;
    };
}
