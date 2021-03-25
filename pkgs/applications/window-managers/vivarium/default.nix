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
  fffSrc = fetchFromGitHub {
    owner = "meekrosoft";
    repo = "fff";
    rev = "7e09f07e5b262b1cc826189dc5057379e40ce886";
    sha256 = "sha256-EY/Ay44+dlJ41ftioCLylcN0g4WLhOLVeskgmsUwQDQ=";
  };
  unitySrc = fetchFromGitHub {
    owner = "ThrowTheSwitch";
    repo = "Unity";
    rev = "0b899aec14d3a9abb2bf260ac355f0f28630a6a3";
    sha256 = "sha256-NokjRgBhOW9EvuZWbNGPqHlQ+OAXJMVZZJf9mXEa+YM=";
  };
in
stdenv.mkDerivation rec {
  pname = "vivarium";
  version = "0.0.2dev";

  src = fetchFromGitHub {
    owner = "inclement";
    repo = "vivarium";
    rev = "5d2abea013be1cc8bdb685fbfeb10b1e30d82cdc";
    sha256 = "sha256-wo7dF969sT18z/vKhEfbWrVfaanq3Cm/gIJTPSD6VMU=";
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

    cp -r ${fffSrc}/ $sourceRoot/subprojects/fff
    cp -r $sourceRoot/subprojects/packagefiles/fff/* $sourceRoot/subprojects/fff

    cp -r ${unitySrc}/ $sourceRoot/subprojects/unity
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
