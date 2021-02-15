{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.drone-server;
in
{

  ###### interface
  options = {
    services.drone-server = {
      enable = mkEnableOption "drone CI server";

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
        description = "DroneCI RPC secret; must match runner's secret.";
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

      # What other options should probably exist?
      # SERVER_PROTO
      # github subModule, gitea submodule, etc etc
      # Database config for something other than sqlite
      # TLS config maybe
    };
  };


  ###### implementation
  config = mkIf cfg.enable {
    # users.users.drone-server #TODO(euank): add a less-privileged user for drone server
    systemd.services.drone-server = {
      description = "drone CI server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # cfg.config with 'DRONE_' prefixed to each key
      environment = mapAttrs' (n: v: (nameValuePair ("DRONE_" + n) v)) cfg.config;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/drone-server";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
