## nixek

This is my overlay of personal packages, modules, etc that I don't think are
ready for the main nix tree yet, but that I wrote for whatever reason.

This is "personal stuff that works on my laptop" quality software, user beware.

Note as well that this loosely tracks nixpkgs unstable, but the actual commit
it tracks is whatever currently seems to be working for me, so it may not work
if upstream has changed significantly.

### Usage

You can get a reference to a set of 'overlayed' packages via something like the following:

```nix
let
  nixek = import <nixos-unstable> {
    overlays = [ (import /home/esk/dev/nix/nixek) ];
    config = {
      allowUnfree = true;
      allowBroken = true;
      # ....
    };
  };
in
{
  # reference 'nixek.pkg' as you like

  # On nixos, if you want to use a module from this, use the following:
  imports =
    [ ./hardware-configuration.nix
      # ...
      nixek.modules.inspircd
    ];
  # use the module per usual
  services.inspircd = { enable = true; package = nixek.inspircd; };
}
```
