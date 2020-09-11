{ callPackage, fetchgit, fetchurl, maven, openjdk11, pkgs, rsync, stdenv, unzip }:

# So, compiling spigot is a bit complicated and requires piecing together some _stuff_.
let
  craftbukkit = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/craftbukkit.git";
    rev = "bf3d7207140a295c35d4024a43cd188824c5a359";
    sha256 = "1ghim98yrdf7s0vyw0rl9976a59jbc6lqvpr22g760fa7ahhbz18";
  };
  spigot = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/spigot.git";
    rev = "3a70bd92b96d836dd046576a57deb7c8573c88a7";
    sha256 = "1ix4a76v4pqd4a7hbh2qsdqr8mykwfyz4jfc3hj1akh2s4p735g7";
  };
  builddata = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/builddata.git";
    rev = "b2025bdddde79aea004399ec5f3652a1bce56b7a";
    sha256 = "0i3fnr909ap10l1pm7hyg0jz52za8104659a8rfhnlbzxnwqa2kl";
  };
  bukkit = fetchgit {
    url = "https://hub.spigotmc.org/stash/scm/spigot/bukkit.git";
    rev = "84fcddbf950c5414164ec4767c77b5a113aeca6e";
    sha256 = "1gzw6nw16y126hkm78pcly1m1z1pri46yn1nbxwfghzk0x1hk79i";
  };
  minecraft = fetchurl {
    url = "https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar";
    sha256 = "0nxdyw23037cr9cfcsfq1cvpy75am5dzmbgvvh3fq6h89kkm1r1j";
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

  version = "1.16.3";
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
    license = stdenv.lib.licenses.unfree;
  };
}
