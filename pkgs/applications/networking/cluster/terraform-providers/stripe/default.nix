{ stdenv, buildGoModule, fetchFromGitHub, libvirt, pkgconfig, makeWrapper, cdrtools }:

buildGoModule rec {
  pname = "terraform-provider-stripe";
  version = "1.6.1";
  src = fetchFromGitHub {
    owner = "franckverrot";
    repo = pname;
    rev = "v${version}";
    sha256 = "1kvgirrkfryp297z7y9170dx5xdkw1iyvqqyaj1a4k7ir8qqslq3";
  };
  vendorSha256 = null;

  postBuild = ''
    mv ../go/bin/terraform-provider-stripe{,_v${version}}
  '';

  meta = with lib; {
    homepage = "https://github.com/franckverrot/terraform-provider-stripe";
    description = "Terraform provider for stripe";
    platforms = platforms.linux;
    license = licenses.mpl20;
  };
}
