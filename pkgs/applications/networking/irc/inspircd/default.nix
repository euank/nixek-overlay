{ stdenv, fetchFromGitHub, pkgconfig, openssl, gnutls, perl }:

stdenv.mkDerivation rec {
  pname = "inspircd";
  version = "3.6.0";

  # A reasonable set of extra modules to build
  extras = [ "m_ssl_openssl.cpp" "m_ssl_gnutls.cpp" "m_sslrehashsignal.cpp" "m_regex_posix.cpp" ];

  src = fetchFromGitHub {
    owner = "inspircd";
    repo = "inspircd";
    sha256 = "1g78qahxaz75c4158p2fid7rzd5dxbgm80gg3fzswsk1pwl1vh9p";
    rev = "v${version}";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ perl openssl gnutls pkgconfig ];

  # So, this package is still not ready for prime-time. Why not?
  # Well, two reasons:
  # 1. the postInstallPhase include stuff below doesn't actually work. No clue
  # why.
  # 2. include probably is being handled wrong, as are modules
  # So for 2, what do I mean? Ideally we want the longer-term thing to be that
  # the inspircd bin is one output (what you run), the modules are another
  # (which the bin loads dynamically), and the include is a third (which is
  # used for compiling out-of-tree modules).
  # Using multiple outputs is something I'm not super familiar with, so I
  # didn't get it working to my satisfaction.
  # I'm going to just leave this bad derivation off in my tree and use it for
  # now, but I'll go back and ask for help on #nixos or on a PR in the future
  # and get this merged.
  configurePhase = ''
    patchShebangs ./configure ./make/unit-cc.pl

    ./configure --enable-extras=${builtins.concatStringsSep "," extras}
    ./configure --disable-interactive \
      --disable-auto-extras \
      --prefix=$prefix \
      --manual-dir=$out/doc \
      --binary-dir=$out/realbin
  '';

  postInstallPhase = ''
    mkdir -p $out/include
    cp -R $src/include $out/include
  '';

  # Sooo, inspircd has two types of binaries it outputs
  # In the '--binary-dir' above, it plops two perl scripts (a service manager
  # one that knows how to stop and start the inspircd bin) and a 'genssl' one.
  # Frankly, I think they're both unneeded on nixos. We can use a systemd
  # service file and generate ssl more reasonably without using those perl
  # scripts imho.
  fixupPhase = ''
    # perl scripts
    rm -rf $out/bin
    # real elf binaries
    mv $out/realbin $out/bin
  '';

  meta = {
    homepage    = "https://www.inspircd.org/";
    description = "A modular C++ IRC server";
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ euank ];
    license     = stdenv.lib.licenses.gpl2Plus;
  };
}
