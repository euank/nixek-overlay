{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "pulumi-sdk";
  version = "2.21.2";

  src = fetchFromGitHub {
    owner = "pulumi";
    repo = "pulumi";
    rev = "v${version}";
    sha256 = "sha256-r7qPu3gTj7Vssf5PgolGeFCVCk1cPlA+mMVOulFeQxA=";
  };
  vendorSha256 = "sha256-+DuQVDfdBJax1gPZcX0CbW1kJKAL1CB2JdXZhxNm/P4=";

  doCheck = false;

  modRoot = "./sdk";
  subPackages = [ "nodejs/cmd/pulumi-language-nodejs" ];

  meta = with lib; {
    description = "Modern Infrastructure as Code tool";
    homepage = "https://www.pulumi.com/";
    license = licenses.asl20;
    maintainers = with maintainers; [ euank ];
    platforms = platforms.unix;
  };
}
