{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, openssl }:

rustPlatform.buildRustPackage rec {
  name = "hashpipe-${version}";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "LinuxMercedes";
    repo = "hashpipe";
    # this PR so we can link against a modern openssl
    # https://github.com/LinuxMercedes/hashpipe/pull/18
    rev = "71fdf34919d7f6c311d5da6c36f0b9c082fce089";
    sha256 = "1iks1apjahibgq9jnk71j15bf2sxar3k0dayj4gjrp19ql7yx7bk";
  };
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ];

  cargoSha256 = "1ss8ai9isfx6pp7ng7mkk21x0zhschg1blrsbmj3vl0178pp7sqp";

  meta = with stdenv.lib; {
    description = "Pipes data to/from IRC";
    homepage = https://github.com/LinuxMercedes/hashpipe;
    license = licenses.gpl3;
    maintainers = [ maintainers.euank ];
    platforms = platforms.all;
  };
}
