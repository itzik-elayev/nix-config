{ self, username, pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      git
      git-lfs
      wget
      curl
      cmake
      (pkgs.writeShellScriptBin "docker-credential-aws-sso-ecr" (builtins.readFile ./local-pkgs/docker-credential-aws-sso-ecr))
      unixtools.watch
      nil
      nixfmt-rfc-style
    ];

    shells = [pkgs.fish];
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
    };

    package = pkgs.nixVersions.latest;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  system = {
    stateVersion = 5;
    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      dock = {
        autohide = true;
        autohide-time-modifier = 0.1;

        show-recents = false;
      };

      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };
  };

  programs = {
    fish = {
      enable = true;
    };
  };

  users = {
    users = {
      ${username} = {
        home = "/Users/${username}";
      };
    };
  };
}