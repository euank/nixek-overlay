{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  name = "hashpipe-${version}";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "LinuxMercedes";
    repo = "hashpipe";
    # this PR so we can link against a modern openssl
    # https://github.com/LinuxMercedes/hashpipe/pull/18
    rev = "71fdf34919d7f6c311d5da6c36f0b9c082fce089";
    hash = "sha256-c53uD8Up3CwfkV41MEdWXQu3SpDhTCsTfitCJa8KesY=";
  };
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  cargoHash = "sha256-celvfzEFi41UoLz3wRKOvwxJSX76PH3SR1Oh0UoT5GA=";

  meta = with lib; {
    description = "Pipes data to/from IRC";
    homepage = "https://github.com/LinuxMercedes/hashpipe";
    license = licenses.gpl3;
    maintainers = [ maintainers.euank ];
    platforms = platforms.all;
  };
}
