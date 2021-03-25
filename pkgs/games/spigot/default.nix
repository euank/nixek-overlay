{ callPackage, fetchgit, fetchurl, maven, openjdk11, pkgs, rsync, stdenv, unzip }:

# So, compiling spigot is a bit complicated and requires piecing together some _stuff_.
let
  craftbukkit = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/craftbukkit.git";
    rev = "3eb7236e443d84d0cb8acb68c9bc6b324e4fbf62";
    sha256 = "0g2xk4ycqyzywi62agi6wd305r3krhm6fv1fgl09r26x0sxjnln0";
  };
  spigot = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/spigot.git";
    rev = "37d799b230195de166af55b0a746310ddcf92bc0";
    sha256 = "12xv1ari5la1zdfbd70nx222m1kw2d9rh0jja0rn8axil0mq26ys";
  };
  builddata = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/builddata.git";
    rev = "501ea060743c7bba4436878207e4f1232298efce";
    sha256 = "1cxy5d2ypqafrszb7ni67rdhxxhkd5qfkbkkzg304qfc1jp628qh";
  };
  bukkit = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/bukkit.git";
    rev = "eda400d3d7f661c78c6128131d76f22f1dc113f5";
    sha256 = "04xn8daamvn48vv0bx8srldyivfwpip6k8fwl2p0hy6aydmj1fv9";
  };
  minecraft = fetchurl {
    url = "https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar";
    sha256 = "01i5nd03sbnffbyni1fa6hsg5yll2h19vfrpcydlivx10gck0ka4";
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

  version = "1.16.4";
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

  mvn2nix = (import (fetchTarball "https://github.com/euank/mvn2nix/archive/9057ed47da403fdbf3b78d2171f4c29e4e429f9c.tar.gz") { });
  apiRepo = mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-spigot-api.lock; };
  spigotRepo = mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-spigot.lock; };

  serverScript = pkgs.writeScript "spigot-mc" ''
    #!/bin/sh
    exec "${pkgs.openjdk11_headless}/bin/java" "$@" -jar "$(dirname $0)/../java/server.jar" nogui
  '';
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
    mkdir -p "$HOME/.m2/repository"
    export XDG_CONFIG_HOME=$HOME
    export MAVEN_OPTS=-Dmaven.repo.local=$HOME/.m2
    export M2_HOME="${maven}"

    rsync -a --chmod "u+w" "${apiRepo}/" "$HOME/.m2/repository/"
    rsync -a --chmod "u+w" "${spigotRepo}/" "$HOME/.m2/repository/"

    mkdir -p "$HOME/.m2/repository/org/spigotmc/minecraft-server/${version}-SNAPSHOT"
    cp "${patchedServer version}" "$HOME/.m2/repository/org/spigotmc/minecraft-server/${version}-SNAPSHOT/minecraft-server-${version}-SNAPSHOT.jar"

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

    mvn --offline -Dmaven.repo.local="$HOME/.m2/repository/" package
  '';

  installPhase = ''
    mkdir -p $out/java
    cp Spigot-Server/target/spigot-${version}-*.jar $out/java/server.jar
    mkdir -p $out/bin
    cp "${serverScript}" "$out/bin/spigot-mc"
  '';

  meta = {
    name = "spigot-mc";
    summary = "Spigot minecraft server software";
    architectures = [ "amd64" ];

    # Unfree because this mixes GPL code with proprietary minecraft server
    # code, and so you can't legally redistribute the output binary.
    # You're in the clear to use it yourself though.
    license = lib.licenses.unfree;
  };
}
