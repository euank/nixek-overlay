{ callPackage, gradleGen, makeWrapper, fetchgit, lib, pkgs, ... }:
let
  jdk = pkgs.jdk15;
  buildGradle = callPackage ./gradle-env.nix {
    gradleGen = gradleGen.override {
      java = jdk;
    };
  };
in
buildGradle {
  version = "1.7.0";
  envSpec = ./gradle-env.json;

  # Patched version from my github so this all works
  src = fetchgit {
    url = "https://github.com/euank/maptool.git";
    rev = "697e9549cf42ac84fe03d74b30ae2f761868f974";
    sha256 = "1ynkklvgr8sb9nspvij8mg4ndn0ss7739blj0l7limb6y2hjabp0";
    # Used for versioning, TODO mock this out somehow
    leaveDotGit = true;
  };

  gradleFlags = [ "installDist" ];

  buildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/realroot $out/bin
    tar -C "$out/realroot" --strip-components=1 -xf build/distributions/MapTool.tar

    patchShebangs $out/realroot/bin/MapTool

    makeWrapper $out/realroot/bin/MapTool $out/bin/MapTool --prefix PATH : ${lib.makeBinPath [ jdk ]}
  '';
}
