self: super: rec {
  haskellPackages = (import ./pkgs/gitit/default.nix) self super;
  # Add a top-level alias, might as well
  gitit = haskellPackages.gitit;

  inspircd = super.callPackage ./pkgs/applications/networking/irc/inspircd {};

  maptool = super.callPackage ./pkgs/games/maptool {};
}
