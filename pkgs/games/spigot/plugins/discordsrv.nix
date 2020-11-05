{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "bukkit-discordsrv";
  version = "1.20.0";
  src = fetchurl {
    url = "https://github.com/DiscordSRV/DiscordSRV/releases/download/v${version}/DiscordSRV-Build-${version}.jar";
    sha256 = "1milz6hbknlam3n3ji9qj2hsmspjs2hl9zbazgydypqj5vkjfbf9";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/plugins
    cp ${src} $out/plugins/DiscordSRV-Build-${version}.jar
  '';

  meta = {
    name = "DiscordSRV";
    summary = "Bukkit plugin to connect minecraft chat to discord";
    architectures = [ "amd64" ];
    license = stdenv.lib.licenses.gpl3;
  };
}
