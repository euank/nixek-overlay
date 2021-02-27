{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "pulumi";
  version = "2.21.2";

  src = fetchFromGitHub {
    owner = "pulumi";
    repo = "pulumi";
    rev = "v${version}";
    sha256 = "sha256-r7qPu3gTj7Vssf5PgolGeFCVCk1cPlA+mMVOulFeQxA=";
  };
  vendorSha256 = "sha256-dGEDqHcg/Da/xLl9JgHRN1jEgHTXzuN5Vo9NgeMS1ls=";

  doCheck = false;

  modRoot = "./pkg";
  subPackages = [ "cmd/pulumi" ];

  preBuild = ''
    pushd ..
    patchShebangs ./scripts
    export PULUMI_VERSION=v${version}
    make generate SHELL=bash
    popd
  '';

  meta = with lib; {
    description = "Modern Infrastructure as Code tool";
    homepage = "https://www.pulumi.com/";
    license = licenses.asl20;
    maintainers = with maintainers; [ euank ];
    platforms = platforms.unix;
  };
}
