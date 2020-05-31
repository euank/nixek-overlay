{ config, lib, pkgs, ... }:

with lib;
let
  attrToConfig = import ./config.nix { inherit lib; };

  cfg = config.services.inspircd;

  configPath = "/etc/inspircd/inspircd.conf";

in
{

  ###### interface

  options = {
    services.inspircd = {
      enable = mkEnableOption "inspircd irc server";

      package = mkOption {
        type = types.package;
        default = pkgs.inspircd;
        defaultText = "pkgs.inspircd";
        description = ''
          inspircd package to use
        '';
      };

      config = mkOption {
        type = types.attrs;
        default = { };
        description = "
          An inspircd config, formatted as a nix expression.
          See the comment at the top of config.nix in the module directory for
          the exact semantics.
        ";
      };

      configFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "
          The path to a config file. This option is optional and overrides 'config' if set.
        ";
      };

      flags = mkOption {
        type = types.str;
        default = "--nopid --nolog";
        description = "
          Flags to pass to inspircd
        ";
      };
    };
  };


  ###### implementation

  config =
    let
      configFile = if cfg.configFile == null then pkgs.writeText "inspircd.conf" (attrToConfig cfg.config) else cfg.configFile;
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.configFile == null -> cfg.config != { };
          message = "config must be set if configFile isn't";
        }
        {
          assertion = cfg.configFile != null -> cfg.config == { };
          message = "One of config or configFile must be set";
        }
      ];

      environment.etc."inspircd/inspircd.conf" = {
        source = configFile;
      };

      users.users.inspircd =
        {
          uid = 320; # config.ids.uids.inspircd; # TODO: this works if we upstream an id, but until then this is easier
          description = "inspircd daemon user";
        };

      systemd.services.inspircd =
        {
          description = "inspircd service";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          stopIfChanged = false;

          serviceConfig = {
            ExecStart = "${cfg.package}/bin/inspircd --nofork ${cfg.flags} --config ${configPath}";
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            User = "inspircd";
            Restart = "always";
            RestartSec = "10s";
          };

          unitConfig.Documentation = "man:inspircd(8)";
        };
      # inspired by https://github.com/NixOS/nixpkgs/blob/d7e569657406f6bb57e29b64d6a5044ddc0d844e/nixos/modules/services/web-servers/nginx/default.nix#L749
      systemd.services.inspircd-config-reload = {
        wants = [ "inspircd.service" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ configFile ];
        serviceConfig.Type = "oneshot";
        serviceConfig.TimeoutSec = 60;
        script = ''
              if /run/current-system/systemd/bin/systemctl -q is-active inspircd.service ; then
          /run/current-system/systemd/bin/systemctl reload inspircd.service
              fi
        '';
        serviceConfig.RemainAfterExit = true;
      };
    };
}
