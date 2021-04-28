{
  description = "my overlay";

  outputs = { self, nixpkgs }: {
    overlay = import ./default.nix;
    packages.x86_64-linux = (import nixpkgs { system = "x86_64-linux"; overlays = [ self.overlay ]; });
  };
}
