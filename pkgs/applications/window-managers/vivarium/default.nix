{ lib, cmake, stdenv, fetchFromGitHub, substituteAll
, meson, ninja, pkg-config, wayland
, libxkbcommon, libinput, gdk-pixbuf, librsvg
, wlroots, wayland-protocols
}:

let # taken from https://github.com/inclement/vivarium/blob/main/subprojects/tomlc99.wrap
  tomlSrc = fetchFromGitHub {
    owner = "cktan";
    repo = "tomlc99";
    rev = "c5d2e37db734fc58f515aaab87d2e037155f6434";
    sha256 = "sha256-TOv0PBlaOW4tpRDhyZ16h3QigHzwp13+KIhs2i2aJgE=";
  };
in
stdenv.mkDerivation rec {
  pname = "vivarium";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "inclement";
    repo = "vivarium";
    rev = "v${version}";
    sha256 = "sha256-ZKRYyq2wxr9B/Makkb9XqaqkZjGPwO7dDrrckzHWVbg=";
  };


  nativeBuildInputs = [
    meson ninja pkg-config wayland cmake
  ];

  buildInputs = [
    wayland libxkbcommon libinput gdk-pixbuf librsvg wlroots wayland-protocols
  ];
  postUnpack = ''
    cp -r ${tomlSrc}/ $sourceRoot/subprojects/tomlc99
    cp -r $sourceRoot/subprojects/packagefiles/tomlc99/* $sourceRoot/subprojects/tomlc99
  '';
  mesonFlags = [ "-Dwerror=false" ];

  meta = with lib; {
    description = "A dynamic tiling wayland compositor";
    longDescription = ''
      Vivarium is a dynamic tiling wayland compositor built using wlroots.
      Core features include dynamic tiling with various layouts,
      xmonad-inspired per-output workspaces, floating-windows as-needed,
      XWayland support, and layer shell support.
      At the time of writing, it's unstable, but usable.
    '';
    homepage    = "https://github.com/inclement/vivarium";
    license     = licenses.gpl3;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ euank ];
  };
}
