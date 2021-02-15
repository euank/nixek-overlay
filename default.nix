self: super: rec {
  modules = {
    inspircd = import ./modules/inspircd;
    spigot-mc = import ./modules/spigot-mc;
    drone-server = import ./modules/drone-server;
    drone-docker-runner = import ./modules/drone-docker-runner;
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

  spigot-mc = super.callPackage ./pkgs/games/spigot {};

  bukkit-plugins = super.callPackage ./pkgs/games/spigot/plugins.nix {};

  tl = super.callPackage ./pkgs/applications/security/tl {};

  terraform-providers = super.terraform-providers // {
    stripe = super.callPackage ./pkgs/applications/networking/cluster/terraform-providers/stripe {};
  };

  nixek-images = super.callPackage ./images { };
}
