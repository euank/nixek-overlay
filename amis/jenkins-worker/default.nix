{ nixpkgs, pkgs }: ((import "${nixpkgs}/nixos/release.nix") {
  configuration = { config, ... }: {
    amazonImage = {
      # raw format so we can upload it directly with coldsnap instead of going
      # through the vm import/export service.
      # In theory, it should be faster to upload a compressed vmdk and have
      # amazon deal with spitting out a snapshot on their end (less network
      # bandwidth).
      # In practice, uploading a 16 gig raw file that's mostly 0 bytes seems
      # quicker. Go figure.
      format = "raw";
      sizeMB = 16 * 1024;
    };

    environment.systemPackages = with pkgs; [
      curl
      jre
    ];

    users.users.jenkins = {
      description = "jenkins user";
      createHome = true;
      home = "/home/jenkins";
      group = "jenkins";
      useDefaultShell = true;
      uid = config.ids.uids.jenkins;
    };

    systemd.services.jenkins-ssh-keys = {
      description = "Add the ec2 ssh key to jenkins authorized keys";
      wantedBy = [ "multi-user.target" ];
      script = ''
        mkdir -m 0700 -p /home/jenkins/.ssh
        chown jenkins /home/jenkins/.ssh
        cat /etc/ec2-metadata/public-keys-0-openssh-key >> /home/jenkins/.ssh/authorized_keys
        chown jenkins /home/jenkins/.ssh/authorized_keys
      '';
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
    };
  };
}).amazonImage.x86_64-linux
