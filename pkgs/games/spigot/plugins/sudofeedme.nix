{ stdenv, spigot-mc, fetchFromGitHub, ant, openjdk11 }:

stdenv.mkDerivation {
  name = "bukkit-sudofeedme";
  src = fetchFromGitHub {
    owner = "euank";
    repo = "SudoFeedme";
    rev = "f6946705e4ea2d1a5f4ba708f3ad03e53f4686e3";
    sha256 = "0hn4ryhnd1y22v1p2ysj6sks5vbqgxzxhig44yagmp3gqx30l4i5";
  };

  nativeBuildInputs = [ ant openjdk11 ];

  buildPhase = ''
    cp ${spigot-mc}/java/server.jar Bukkit.jar
    ant
  '';

  installPhase = ''
    mkdir -p $out/plugins
    cp dist/SudoFeedme.jar $out/plugins
  '';

  meta = {
    name = "SudoFeedme";
    summary = "Bukkit plugin to blunt minecraft starvation mechanics";
    architectures = [ "amd64" ];
    # Unfree because I forgot to slap a gpl license on this.
    # Happy to do so if anyone wants me to btw, just lemme know.
    license = lib.licenses.unfree;
  };
}
