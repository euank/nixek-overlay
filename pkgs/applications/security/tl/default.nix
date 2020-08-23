{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "tl";
  version = "0.2.12";

  src = fetchFromGitHub {
    owner = "transparencylog";
    repo = "tl";
    rev = "v${version}";
    sha256 = "1h0cfzvx3rnwhvnwcishi08xl9dk254p7nzsi6db3c3d8cs2y04y";
  };

  vendorSha256 = null;

  subPackages = [ "." ];

  meta = with lib; {
    description = "CLI for the asset transparency log";
    homepage = "https://www.transparencylog.com/";
    license = licenses.asl20;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
