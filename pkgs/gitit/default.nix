self: super:
with self.haskell.lib; super.haskellPackages.extend (selfHS: superHS: {
  gitit = overrideCabal superHS.gitit (oa: {
    src = super.fetchFromGitHub {
      owner = "jgm";
      repo = "gitit";
      rev = "fb8301b5af5ba8a1ca9ae83a7f4cd213c6149a03";
      sha256 = "08faxzffzx54qyb181dyjyzn870zl573q6y213s5rd85f6zvaijr";
    };
  });
})
