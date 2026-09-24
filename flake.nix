{
  description = "Itzhak Alayev nix configuration for darwin";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    # nixpkgs bumped kubernetes-helm from 3.20.2 to 4.2.0, and Helm 4's new
    # plugin manifest schema breaks plugins that haven't migrated yet (e.g.
    # helm-cm-push). Pin to the last revision before that bump.
    nixpkgs-helm3 = {
      url = "github:NixOS/nixpkgs/a50faf4c47054e640207d2f0c7d00ed8b84e0999";
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
    nixpkgs-helm3,
    nix-darwin,
    home-manager,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    ...
  }: let
    username = "itzhakalayev";
    system = "aarch64-darwin";
    pkgs-helm3 = nixpkgs-helm3.legacyPackages.${system};

    mkDarwinSystem = { username, additionalModules ? [] }:
      nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self username system; };
        modules = [
          ./systems/common.nix
          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home/common.nix;
              backupFileExtension = "bk";
              extraSpecialArgs = {
                inherit username pkgs-helm3;
              };
            };
          }
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
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
