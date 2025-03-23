{ pkgs, username, ... }: {
  nixpkgs.config.allowUnfree = true;

  home = {
    username = username;

    stateVersion = "23.11";

    packages = with pkgs; [
      # programming languages related packages
      go
      golangci-lint
      go-task
      python3

      # cloud tools packages
      awscli2
      amazon-ecr-credential-helper
      ssm-session-manager-plugin
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      azure-cli
      terraform
      terraform-ls
      packer

      # container related packages
      docker
      colima
      skopeo
      dive
      trivy

      # kubernetes related packages
      kubectl
      kubernetes-helm
      k9s
      k3d
      kubectx
      ctlptl
      ocm
      vals
      argocd
      tilt
      consul
      vault

      # text file utils
      jq
      yq-go
      ripgrep
      xmlstarlet

      # terminal related stuff
      iterm2
      eza
      tmux
      nnn

      # misc
      fzf
      unzip
      darwin.iproute2mac
      gh
      jfrog-cli
      postgresql

      # comms
      slack

      # networking
      inetutils

      # fonts
      meslo-lgs-nf
    ];

    sessionVariables = {
      SHELL = "fish";
      EDITOR = "vim";
    };
  };

  xdg = {
    enable = true;

    configFile = {
      "karabiner/karabiner.json" = {
        source = ./configs/karabiner/karabiner.json;
        force = true;
      };
    };
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager = {
      enable = true;
      
    };

    fish = {
      enable = true;

      plugins = [];

      shellInit = ''
        bind \e\x7F 'backward-kill-word'
      '';

      shellAliases = {
        k = "kubectl";
        kctx = "kubectx";
        kns = "kubens";

        tf = "terraform";

        ls = "eza --all --icons=always --git-repos";
        ll = "ls -la";

        rebuild = "darwin-rebuild switch --flake .";

        code = "open -a 'Visual Studio Code'";
        idea = "open -a 'IntelliJ IDEA'";

        flushdns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
      };
    };

    git = {
      enable = true;

      userName = "Itzhak Alayev";

      extraConfig = {
        push.autoSetupRemote = true;
        pull.rebase = false;
        color.ui = "auto";
        core.editor = "vim";
      };
    };
  };
}