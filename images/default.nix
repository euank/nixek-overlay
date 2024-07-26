{ pkgs }:
{
  synapse = pkgs.callPackage ./servers/matrix-synapse/default.nix { };
  syncplay-server = pkgs.callPackage ./servers/syncplay { };
  wal-g = pkgs.callPackage ./tools/wal-g.nix { };
}
