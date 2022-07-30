{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "euank/synapse";
  tag = "${pkgs.matrix-synapse.version}-2";
  contents = with pkgs; [
    matrix-synapse
    cacert
    bashInteractive
  ];
  config = {
    Entrypoint = [
      "/bin/synapse_homeserver" "--config-path" "/conf/homeserver.yaml"
    ];
    Env = [
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    ];
    Cmd = [ ];
  };
}
