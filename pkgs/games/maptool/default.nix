{ callPackage, gradleGen, openjdk14, makeWrapper, fetchgit, lib, pkgs, ... }:

let
  buildGradle = callPackage ./gradle-env.nix { };
in
buildGradle rec {
  version = "1.8.5";
  rev = "8ed806d1204d8e49d7f87268e06f5c8dd83af8ef";
  envSpec = ./gradle-env.json;
  buildJdk = openjdk14;

  src = fetchgit {
    inherit rev;
    url = "https://github.com/euank/maptool";
    sha256 = "sha256-68kF/ujflLvjYJFTiCX9aqrCL4ynfwOwYrQxdcxZ0iA=";
  };


  gradleFlags = [ "-PnoGit=true" "-PgitTag=${version}" "-PgitCommit=${rev}" "distTar" ];

  installPhase = ''
    mkdir -p $out
    tar -xvf build/distributions/MapTool.tar --strip-components=1 -C $out
  '';
}
