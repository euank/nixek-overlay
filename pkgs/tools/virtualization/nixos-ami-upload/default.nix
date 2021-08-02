{ lib, rustPlatform, fetchFromGitHub, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "nixos-ami-upload";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "euank";
    repo = pname;
    rev = "4b5bdaa6ed38d042942b57198de41a15829168fd";
    sha256 = "sha256-gC9tsh7VRNfM6Y+nTpKo3M955JvRJ5o4KGIDj6h21QI=";
  };

  cargoSha256 = "sha256-03/wd/gAAUeZcF5HiCCBESwPej1bdBVR/U4FhlUrhOw=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Command line utility to upload nixos AMIs";
    homepage = "https://github.com/euank/nixos-ami-upload";
    maintainers = [ maintainers.euank ];
  };
}
