{ config, lib, pkgs, ... }:

with lib;
let
  attrToConfig = import ./config.nix { inherit lib; };

  cfg = config.services.inspircd;

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

  config = mkIf cfg.enable {
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


    users.users.inspircd =
      {
        uid = 320; # config.ids.uids.inspircd; # TODO: this works if we upstream an id, but until then this is easier
        description = "inspircd daemon user";
      };

    systemd.services.inspircd =
      let
        configFile = if cfg.configFile == null then pkgs.writeText "inspircd.conf" (attrToConfig cfg.config) else cfg.configFile;
      in
      {
        description = "inspircd service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/inspircd --nofork --nolog ${cfg.flags} --config ${configFile}";
          User = "inspircd";
        };

        unitConfig.Documentation = "man:inspircd(8)";
      };
  };
}
