{ pkgs, nixpkgs }:
{
  jenkins-worker = pkgs.callPackage ./jenkins-worker { inherit nixpkgs; };
}
