{ config ? {}}:
# This contains a resolved version of this overlay, useful for building images within it, testing, etc.
let
  nixpkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/0f976477e9f61578c5f7f0a33830cfaa81168d75.tar.gz") {
    overlays = [
      (import ./.)
    ];
    inherit config;
  };
in
  nixpkgs
