{ config ? {}}:
# This contains a resolved version of this overlay, useful for building images within it, testing, etc.
let
  nixpkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/4cb48cc25622334f17ec6b9bf56e83de0d521fb7.tar.gz") {
    overlays = [
      (import ./.)
    ];
    inherit config;
  };
in
  nixpkgs
