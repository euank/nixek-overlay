{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "euank/synapse";
  tag = "${pkgs.matrix-synapse.version}-1";
  contents = with pkgs; [
    matrix-synapse
    cacert
  ];
  config = {
    Entrypoint = [
      "/bin/homeserver" "--config-path" "/conf/homeserver.yaml"
    ];
    Env = [
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    ];
    Cmd = [ ];
  };
}
