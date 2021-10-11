{ pkgs }:
{
  synapse = pkgs.callPackage ./servers/matrix-synapse/default.nix { };
  syncplay-server = pkgs.callPackage ./servers/syncplay { };
}
