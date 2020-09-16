{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "bukkit-discordsrv";
  version = "1.19.1";
  src = fetchurl {
    url = "https://github.com/DiscordSRV/DiscordSRV/releases/download/v${version}/DiscordSRV-Build-${version}.jar";
    sha256 = "08jlb5d8h14p8834ga3aj7kzxk3692hj8awh7z9j1r2844amy7ic";
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
