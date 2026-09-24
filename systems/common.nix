{ self, username, pkgs, ... }:
let
  homeDir = "/Users/${username}";
in
{
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
        # packer's vendored go-m1cpu segfaults on M4/M5 during checkPhase (missing
        # IOKit null-check). Drop once nixpkgs bumps go-m1cpu >= 0.2.1.
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
        home = homeDir;
      };
    };
  };

  # users.<name>.shell only applies to users.knownUsers, which nix-darwin warns
  # against for admin accounts (it also drives deletion). Set the shell by hand.
  system.activationScripts.postActivation.text = ''
    fishPath="${pkgs.fish}/bin/fish"
    currentShell=$(dscl . -read "${homeDir}" UserShell 2>/dev/null | awk '{print $2}')
    if [ "$currentShell" != "$fishPath" ]; then
      echo "setting login shell for ${username} to fish..." >&2
      dscl . -create "${homeDir}" UserShell "$fishPath"
    fi

    # nix-darwin kills Dock each activation to reload system.defaults; macOS 26
    # launchd can fail to respawn it (nix-darwin#1856), freezing Spaces. Force up.
    userId=$(id -u "${username}")
    launchctl kickstart "gui/$userId/com.apple.Dock.agent" || true
  '';
}
