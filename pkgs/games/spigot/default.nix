{ callPackage, fetchgit, fetchurl, maven, openjdk11, pkgs, rsync, stdenv, unzip }:

# So, compiling spigot is a bit complicated and requires piecing together some _stuff_.
let
  craftbukkit = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/craftbukkit.git";
    rev = "7d8884b263a7f9f1bfb7aa63bd1f0767f1382bf3";
    sha256 = "0yyv9dgldabab2zrx6dx7q7pn97z25mxfg460vvj9wbcp18l9vly";
  };
  spigot = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/spigot.git";
    rev = "379750e0474d4ed87bbbf715545fe2e75c0ca4e9";
    sha256 = "1xb72735vznfqlz5p6p6akh02gw3q5fpmiwvgrqjgza0j9gyc9d1";
  };
  builddata = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/builddata.git";
    rev = "2589242ccafbffaeb0a36d16e9f59f97ab3411b7";
    sha256 = "1dpd5hq9xhdbd16maajqj1pxrr2jzm0xg9xd2jgynl6pg507ghb1";
  };
  bukkit = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/bukkit.git";
    rev = "18e9d9315b72ee85bff8ba10c849b72f994f9ae1";
    sha256 = "1ci9rraz96wdjcrf8ixbka2pmgdqsk0qlrs2hjsvs7n85vi5w8ip";
  };
  minecraft = fetchurl {
    url = "https://launcher.mojang.com/v1/objects/c5f6fb23c3876461d46ec380421e42b289789530/server.jar";
    sha256 = "0fbghwrj9b2y9lkn2b17id4ghglwvyvcc8065h582ksfz0zys0i9";
  };

  clMapped = version: pkgs.runCommand "minecraft-cl" {} ''
    ${openjdk11}/bin/java -jar ${builddata}/bin/SpecialSource-2.jar map \
      --only . \
      --only net/minecraft \
      --auto-lvt BASIC \
      --auto-member SYNTHETIC \
      -e ${builddata}/mappings/bukkit-${version}.exclude \
      -i ${minecraft} \
      -m ${builddata}/mappings/bukkit-${version}-cl.csrg \
      -o $out
  '';
  mMapped = version: pkgs.runCommand "minecraft-m" {} ''
    ${openjdk11}/bin/java -jar ${builddata}/bin/SpecialSource-2.jar map \
      --only . --only net/minecraft \
      --auto-member LOGGER --auto-member TOKENS \
      -i ${clMapped version} \
      -m ${builddata}/mappings/bukkit-${version}-members.csrg \
      -o $out
  '';
  patchedServer = version: pkgs.runCommand "minecraft-patched" {} ''
    ${openjdk11}/bin/java -jar ${builddata}/bin/SpecialSource.jar \
      --only . --only net/minecraft \
      -i ${mMapped version} --access-transformer ${builddata}/mappings/bukkit-${version}.at \
      -m ${builddata}/mappings/package.srg \
      -o $out
  '';
  decompiled = version: pkgs.runCommand "minecraft-decompiled" {} ''
    mkdir -p $out/classes
    ${unzip}/bin/unzip -d $out/classes ${patchedServer version} 'net/minecraft/server/*'

    ${openjdk11}/bin/java -jar ${builddata}/bin/fernflower.jar \
      -dgs=1 -hdc=0 -asc=1 -udv=0 -rsy=1 -aoa=1 \
      $out/classes $out
  '';

  version = "1.16.2";
  patchedCraftbukkit = stdenv.mkDerivation {
    name = "craftbukkit";
    inherit version;
    src = craftbukkit;
    buildPhase = ''
      for fi in nms-patches/*.patch; do
        bn=$(basename $fi)
        javaName="''${bn%.patch}.java"
        tgt="net/minecraft/server/$javaName"
        clean="${decompiled version}/$tgt"
        mkdir -p "src/main/java/$(dirname $tgt)"
        patch -p1 -o src/main/java/$tgt $clean $fi
      done
    '';
    installPhase = ''
      mkdir $out
      cp -r * $out
    '';
  };

in
stdenv.mkDerivation rec {
  name = "spigot";
  inherit version;

  src = spigot;

  nativeBuildInputs = [ openjdk11 maven rsync unzip ];

  unpackPhase = ''
    runHook preUnpack

    cp -rT $src .
    rsync -a --chmod "u+w" ${patchedCraftbukkit}/ Spigot-Server/
    rsync -a --chmod "u+w" ${bukkit}/ Spigot-API/
    export sourceRoot=$(pwd)

    runHook postUnpack
  '';

  buildPhase = ''
    export HOME="$(mktemp -d)"
    export XDG_CONFIG_HOME=$HOME
    export MAVEN_OPTS=-Dmaven.repo.local=$HOME/.m2
    export M2_HOME="${maven}"

    mvn install:install-file -Dfile=${patchedServer version} -Dpackaging=jar -DgroupId=org.spigotmc -DartifactId=minecraft-server -Dversion=${version}-SNAPSHOT

    # And another round of patching
    pushd Spigot-Server
    for p in ../CraftBukkit-Patches/*.patch; do
      patch -p1 < $p
    done
    popd
    pushd Spigot-API
    for p in ../Bukkit-Patches/*.patch; do
      patch -p1 < $p
    done
    popd

    mvn clean install
  '';

  installPhase = ''
    cp Spigot-Server/target/spigot-${version}-*.jar $out
  '';

  # sha256 = "73cb3858a687a8494ca3323053016282f3dad39d42cf62ca4e79dda2aac7d9ac";
  outputHash = "sha256:0x9cj5gczi6c1hlklmjx0nyw8r1padwjfwyd4ni17z18id0fnxi1";

  meta = {
    name = "spigot-mc";
    summary = "Spigot minecraft server software";
    architectures = [ "amd64" ];

    # Unfree because this mixes GPL code with proprietary minecraft server
    # code, and so you can't legally redistribute the output binary.
    # You're in the clear to use it yourself though.
    license = stdenv.lib.licenses.unfree;
  };
}
