{ username, system, ... }: {
  nixpkgs = {
    hostPlatform = system;
  };

  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
    };

    # nix-homebrew keeps these tapped (mutableTaps = false); list them so
    # `brew bundle cleanup --zap` doesn't try to untap them every activation.
    taps = [
      "homebrew/core"
      "homebrew/cask"
    ];

    casks = import ./casks.nix;

    masApps = {
      Amphetamine = 937984704;
    };
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
