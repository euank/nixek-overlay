{ lib, stdenv, fetchFromGitHub, unzip }:

stdenv.mkDerivation rec {
  pname = "meslolgs-nf";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "romkatv";
    repo = "powerlevel10k-media";
    rev = "54fbc18ea84d15807f921146c1689539b62a6061";
    sha256="03nzksq2ghclwbrsbg84lqq3n4ngr1vq4yi3qipm7qyvavc4d4mx";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp *.ttf $out/share/fonts/truetype
  '';

  outputs = [ "out" ];

  meta = {
    description = "Meslo Nerd Font";
    homepage = "https://github.com/romkatv/powerlevel10k-media/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ euank ];
    platforms = with lib.platforms; all;
  };
}
