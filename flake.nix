{
  description = "Itzhak Alayev nix configuration for darwin";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    ... 
  }: let
    username = "itzhakalayev";

    mkDarwinSystem = { username, additionalModules ? [] }:
      nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self; inherit username; };
        modules = [
          ./systems/common.nix
          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home/common.nix;
              backupFileExtension = "bk";
              extraSpecialArgs = {
                inherit username;
              };
            };
          }
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;

              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };

              mutableTaps = false;
              autoMigrate = true;
            };
          }
        ] ++ additionalModules;
      };
  in {
    darwinConfigurations = {
      "mbpro" = mkDarwinSystem {
        inherit username;
        additionalModules = [ ./systems/darwin.nix ];
      };
    };
  };
}
