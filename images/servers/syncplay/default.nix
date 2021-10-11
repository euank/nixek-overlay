{ pkgs }:

let
  entrypoint = ./entrypoint.sh;
in
pkgs.dockerTools.buildLayeredImage {
  name = "euank/syncplay-server";
  tag = "${pkgs.syncplay.version}-1";
  contents = with pkgs; [
    syncplay
    coreutils
    bash
    cacert
  ];
  config = {
    Env = [
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    ];
    Cmd = [
      "${entrypoint}"
    ];
  };
}
