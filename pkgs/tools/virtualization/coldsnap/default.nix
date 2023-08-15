{ lib, rustPlatform, fetchFromGitHub, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "coldsnap";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-zXLt16ffqbExU23uRI7U99nUwpSKTIf039dDq+k2KAA=";
  };

  cargoHash = "sha256-RRyAzD9eiscZ9kB5tFh5vUnGk6XYYKy0/TAjcaygmG4=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = " A command line interface for Amazon EBS snapshots ";
    homepage = "https://github.com/awslabs/coldsnap";
    maintainers = [ maintainers.euank ];
  };
}
