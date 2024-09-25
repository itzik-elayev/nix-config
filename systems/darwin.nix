{ self, pkgs, ... }: {
  nix = {
    linux-builder = {
      enable = true;
    };

    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
  };

  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
    };

    casks = import ../home/homebrew/common.nix ++ import ../home/homebrew/work.nix;
  };
}