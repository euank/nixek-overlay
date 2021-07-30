{ lib, rustPlatform, fetchFromGitHub, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "coldsnap";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-wgQKbEU0ig1jcAAL0WE7lNL7g9WKjVaIl0a7GWxkpXM=";
  };

  cargoSha256 = "sha256-4D+0lyiHitiapQ88Wguh/JsH2l+wA2OiBivIUPslsuo=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = " A command line interface for Amazon EBS snapshots ";
    homepage = "https://github.com/awslabs/coldsnap";
    maintainers = [ maintainers.euank ];
  };
}
