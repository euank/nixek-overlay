{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.spigot-mc;
  whitelistFile = pkgs.writeText "whitelist.json"
    (
      builtins.toJSON
        (mapAttrsToList (n: v: { name = n; uuid = v; }) cfg.whitelist)
    );

  cfgToString = v: if builtins.isBool v then boolToString v else toString v;
  serverPropertiesFile = pkgs.writeText "server.properties" (
    ''
      # server.properties managed by NixOS configuration
    '' + concatStringsSep "\n" (
      mapAttrsToList
        (n: v: "${n}=${cfgToString v}") cfg.serverProperties
    )
  );

  eulaFile = pkgs.writeText "eula.txt" "eula=true";

in
{

  ###### interface

  # Note: heavily inspired by upstream:
  # https://github.com/NixOS/nixpkgs/blob/6f6468bef34394b5c63aaa46fe20965993420600/nixos/modules/services/games/minecraft-server.nix
  # Partially Copyright Eelco & NixOS contributors, MIT license

  options = {
    services.spigot-mc = {
      enable = mkEnableOption "spigot minecraft server";

      package = mkOption {
        type = types.package;
        default = pkgs.spigot-mc;
        defaultText = "pkgs.spigot-mc";
        description = ''
          spigot-mc package to use
        '';
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/minecraft";
        description = ''
          Path to the minecraft server data directory.
          Must be owned by the minecraft user.
        '';
      };

      eula = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether you agree to
          <link xlink:href="https://account.mojang.com/documents/minecraft_eula">
          Mojangs EULA</link>. This option must be set to
          <literal>true</literal> to run Minecraft server.
        '';
      };

      whitelist = mkOption {
        type = let
          minecraftUUID = types.strMatching
            "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" // {
            description = "Minecraft UUID";
          };
        in
          types.attrsOf minecraftUUID;
        default = {};
        description = ''
          Whitelisted players, only has an effect when
          <option>services.minecraft-server.declarative</option> is
          <literal>true</literal> and the whitelist is enabled
          via <option>services.minecraft-server.serverProperties</option> by
          setting <literal>white-list</literal> to <literal>true</literal>.
          This is a mapping from Minecraft usernames to UUIDs.
          You can use <link xlink:href="https://mcuuid.net/"/> to get a
          Minecraft UUID for a username.
        '';
        example = literalExample ''
          {
            username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
            username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
          };
        '';
      };

      serverProperties = mkOption {
        type = with types; attrsOf (oneOf [ bool int str ]);
        default = {};
        example = literalExample ''
          {
            server-port = 43000;
            difficulty = 3;
            gamemode = 1;
            max-players = 5;
            motd = "NixOS Minecraft server!";
            white-list = true;
            enable-rcon = true;
            "rcon.password" = "hunter2";
          }
        '';
        description = ''
          Minecraft server properties for the server.properties file. Only has
          an effect when <option>services.minecraft-server.declarative</option>
          is set to <literal>true</literal>. See
          <link xlink:href="https://minecraft.gamepedia.com/Server.properties#Java_Edition_3"/>
          for documentation on these values.
        '';
      };


      jvmOpts = mkOption {
        type = types.str;
        default = "-Xmx3096M -Xms2048M -XX:+UseG1GC -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
        description = "
          jvm options for the minecraft jar
        ";
      };

      plugins = mkOption {
        type = types.listOf types.package;
        default = [];
        description = ''
          List of bukkit plugins
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {
    users.users.minecraft = {
      uid = config.ids.uids.minecraft;
      home = cfg.dataDir;
      createHome = false;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 minecraft root -"
    ];

    systemd.services.spigot-mc =
      let
        preStart = ''
          ln -sf ${eulaFile} eula.txt

          ln -sf ${whitelistFile} whitelist.json
          cp -f ${serverPropertiesFile} server.properties

          # Minecraft rewrites the file
          chmod +w server.properties

          for plugin in ${concatStringsSep " " cfg.plugins}; do
            echo "Installing plugin $plugin"
            mkdir -p plugins
            [ -d $plugin/plugins ] && ln -sf $plugin/plugins/* plugins
          done
        '';
      in
        {
          description = "spigot-mc minecraft server service";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            ExecStart = "${cfg.package}/bin/spigot-mc ${cfg.jvmOpts}";
            User = "minecraft";
            WorkingDirectory = cfg.dataDir;
            Restart = "always";
            RestartSec = "10s";
          };

          inherit preStart;
        };

    assertions = [
      {
        assertion = cfg.eula;
        message = "You must agree to Mojangs EULA to run minecraft-server."
        + " Read https://account.mojang.com/documents/minecraft_eula and"
        + " set `services.minecraft-server.eula` to `true` if you agree.";
      }
    ];
  };
}
