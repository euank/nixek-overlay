{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "euank/wal-g";
  tag = "${pkgs.wal-g.version}-1";
  contents = with pkgs; [
    wal-g
    cacert
    bashInteractive
  ];
  config = {
    Entrypoint = [
      "/bin/bash"
    ];
    Env = [
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    ];
    Cmd = [ ];
  };
}
