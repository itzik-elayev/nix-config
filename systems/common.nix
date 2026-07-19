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
      nixfmt
    ];

    shells = [pkgs.fish];
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = ["root" username];
    };

    package = pkgs.nixVersions.latest;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };

    overlays = [
      (final: prev: {
        # packer's vendored go-m1cpu segfaults on M4/M5 chips during checkPhase
        # (missing null-check for an IOKit property that's absent on newer Apple Silicon).
        # Remove this once nixpkgs bumps go-m1cpu to >=0.2.1.
        packer = prev.packer.overrideAttrs (old: {
          doCheck = false;
        });
      })
    ];
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