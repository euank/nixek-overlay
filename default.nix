self: super: rec {
  modules = {
    inspircd = import ./modules/inspircd/default.nix;
  };

  haskellPackages = (import ./pkgs/gitit/default.nix) self super;
  # Add a top-level alias, might as well
  gitit = haskellPackages.gitit;

  hashpipe = super.callPackage ./pkgs/applications/networking/irc/hashpipe {};

  inspircd = super.callPackage ./pkgs/applications/networking/irc/inspircd {};

  inspircd2 = super.callPackage ./pkgs/applications/networking/irc/inspircd2 {};

  maptool = super.callPackage ./pkgs/games/maptool {};

  np2kai = super.callPackage ./pkgs/misc/emulators/np2kai {};

  meslolgs-nf = super.callPackage ./pkgs/data/fonts/meslolgs-nf {};

  nixek-images = super.callPackage ./images { };
}
