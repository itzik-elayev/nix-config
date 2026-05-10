{ username, ... }: {
  nix = {
    linux-builder = {
      enable = true;
    };

    settings = {
      extra-platforms = ["x86_64-darwin" "aarch64-darwin"];
    };
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
  };

  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
    };

    casks = import ../homebrew/personal.nix ++ import ../homebrew/work.nix;
  };

  launchd.user.agents.fixcaps = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--set"
        ''{"CapsLockDelayOverride":10}''
      ];
      RunAtLoad = true;
    };
  };

  system = {
    primaryUser = username;
  };
}
