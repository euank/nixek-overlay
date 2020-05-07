{ callPackage, gradleGen, makeWrapper, fetchgit, lib, pkgs, ... }:
let
  buildGradle = callPackage ./gradle-env.nix {
    gradleGen = gradleGen.override {
      java = pkgs.jdk11;
    };
  };
in
buildGradle {
  envSpec = ./gradle-env.json;

  # Patched version from my github so this all works
  src = fetchgit {
    url = "https://github.com/euank/maptool.git";
    rev = "9fc4f5ad12e5f430c9113b7d20150495152dd6f4";
    sha256 = "1kbgji6g4mgg80xpjfzxb8lrp81w80whvvlypfa6l8afdg9x0jw3";
    # Used for versioning, TODO mock this out somehow
    leaveDotGit = true;
  };

  gradleFlags = [ "distTar" ];

  buildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/realroot $out/bin
    tar -C "$out/realroot" --strip-components=1 -xf build/distributions/MapTool.tar

    patchShebangs $out/realroot/bin/MapTool

    makeWrapper $out/realroot/bin/MapTool $out/bin/MapTool --prefix PATH : ${lib.makeBinPath [ pkgs.jdk11 ]}

  '';
}