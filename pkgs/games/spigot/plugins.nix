{ callPackage }:

{
  sudofeedme = callPackage ./plugins/sudofeedme.nix { };
  discordsrv = callPackage ./plugins/discordsrv.nix { };
}
