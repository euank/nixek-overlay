{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.drone-docker-runner;
in
{

  ###### interface
  options = {
    services.drone-docker-runner = {
      enable = mkEnableOption "drone CI docker runner";

      package = mkOption {
        type = types.package;
        default = pkgs.drone;
        defaultText = "pkgs.drone";
        description = ''
          drone package to use the drone-server binary of
        '';
      };

      serverHost = mkOption {
        type = types.str;
        description = "Server host, such as 'drone.example.com'.";
      };

      rpcSecret = mkOption {
        type = types.str;
        description = "DroneCI RPC secret; must match server's secret.";
      };

      config = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Extra drone config options in the format "OPTION_NAME" = "value";,
          where "OPTION_NAME" is the environment variable associated with that
          configuration, excluding the 'DRONE_' prefix.
        '';
      };
    };
  };


  ###### implementation
  config = mkIf cfg.enable {
    # users.users.drone-runner-user #TODO(euank): add a less-privileged user for this

    virtualisation.docker.enable = true;

    systemd.services.drone-docker-runner = {
      description = "drone CI docker runner";
      after = [ "network.target" "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      # cfg.config with 'DRONE_' prefixed to each key
      environment = mapAttrs' (n: v: (nameValuePair ("DRONE_" + n) v)) cfg.config;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/drone-agent";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
