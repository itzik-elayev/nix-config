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

      CustomUserPreferences = {
        "com.caldis.Mos" = {
          reverse = true;
          reverseHorizontal = true;
          reverseVertical = true;

          smooth = true;
          smoothHorizontal = true;
          smoothVertical = true;
          smoothSimTrackpad = false;

          speed = 5.344623659412745;
          step = 10.0;
          deadZone = 1;
          duration = 1;

          allowlist = false;
          hideStatusItem = false;
          updateCheckOnAppStart = false;
          updateIncludingBetaVersion = false;
        };
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

  # nix-darwin only manages UserShell for accounts in users.knownUsers, which its
  # own docs warn against adding admin accounts to (that list also drives account
  # deletion). Set the login shell for the primary account by hand instead.
  system.activationScripts.postActivation.text = ''
    fishPath="${pkgs.fish}/bin/fish"
    currentShell=$(dscl . -read "/Users/${username}" UserShell 2>/dev/null | awk '{print $2}')
    if [ "$currentShell" != "$fishPath" ]; then
      echo "setting login shell for ${username} to fish..." >&2
      dscl . -create "/Users/${username}" UserShell "$fishPath"
    fi
  '';
}
