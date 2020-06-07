{ stdenv, git, gtk2, fetchgit, cmake
, SDL2, SDL2_gfx, SDL2_image, SDL2_mixer, SDL_mixer, SDL2_net, SDL2_ttf, SDL, SDL_ttf
, pkg-config, glib, pcre, openssl }:

stdenv.mkDerivation {
  name = "np2kai";

  src = fetchgit {
    url = "https://github.com/AZO234/NP2kai.git";
    rev = "6d461afcb6dd294829e81400573d6fa79e1a0fb1";
    sha256 = "19j8djam9k3ndvz70b3yk29xl54fbpnsy4nhd6js5gwrgq3v6yrg";
  };

  cmakeFlags = [
    "-DGTK2_GDKCONFIG_INCLUDE_DIR=${gtk2.out}/lib/gtk-2.0/include"
    "-DGTK2_GLIBCONFIG_INCLUDE_DIR=${glib.out}/lib/glib-2.0/include"
  ];

  nativeBuildInputs = [ cmake git ];
  buildInputs = [
    SDL2 SDL2_gfx SDL2_image SDL2_mixer SDL2_net SDL2_ttf pkg-config
    glib pcre gtk2 SDL SDL_ttf openssl SDL_mixer
  ];
}
