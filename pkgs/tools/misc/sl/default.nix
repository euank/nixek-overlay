{ lib, stdenv, fetchzip, ncurses }:

stdenv.mkDerivation rec {
  pname = "sl";
  version = "3.03";

  src = fetchzip {
    url = "https://github.com/euank/docker-sl/raw/c605aaacb0078fecc864e5f1726d7bbea2d01623/sl.tar";
    hash = "sha256-Uh95tE6h4U9Q4s/gvECifjIODlXvjnK//6Ar47ijn14=";
  };

  patches = [
    ./sl5-1.patch
    ./sl5-2.patch
  ];

  buildInputs = [ ncurses ];

  makeFlags = [ "CC:=$(CC)" "CFLAGS:=$(CFLAGS)" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin sl
    install -Dm644 -t $out/share/man/man1 sl.1

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steam Locomotive runs across your terminal when you type 'sl'";
    homepage = "http://www.tkl.iis.u-tokyo.ac.jp/~toyoda/index_e.html";
    license = rec {
      shortName = "Toyoda Masashi's free software license";
      fullName = shortName;
      url = "https://github.com/eyJhb/sl/blob/master/LICENSE";
    };
    maintainers = with maintainers; [ euank ];
    platforms = platforms.unix;
  };
}
