{ pkgs }:
{
  synapse = pkgs.callPackage ./servers/matrix-synapse/default.nix { };
}
