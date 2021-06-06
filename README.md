## nixek

This is my overlay of personal packages, modules, etc that I don't think are
ready for the main nix tree yet, but that I wrote for whatever reason.

This is "personal stuff that works on my laptop" quality software, user beware.

Note as well that this loosely tracks nixpkgs unstable, but the actual commit
it tracks is whatever currently seems to be working for me, so it may not work
if upstream has changed significantly.

### Usage

This overlay is meant to be used with nix flakes.

It may be used like so as a flake input:

```nix
inputs.ekverlay.url = "github:euank/nixek-overlay";

outputs = { self, nixpkgs, ekverlyay }:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [
        ekverlay.overlay
      ];
      config = { allowUnfree = true; };
    };
  in {
    # Normal outputs here, using the 'pkgs' reference above.
  };
```
