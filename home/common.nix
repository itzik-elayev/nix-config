{ pkgs, username, ... }: {
  home = {
    username = username;

    stateVersion = "23.11";

    packages = with pkgs; [
      go
      golangci-lint
      go-task
      python3
      python3Packages.pip
      awscli2
      amazon-ecr-credential-helper
      ssm-session-manager-plugin
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      azure-cli
      terraform
      terraform-ls
      tflint
      packer
      docker
      skopeo
      dive
      trivy
      snyk
      kubectl
      kubectl-node-shell
      kubernetes-helm
      helm-docs
      k9s
      k3d
      kind
      kubectx
      ctlptl
      ocm
      crc
      vals
      argocd
      tilt
      consul
      vault
      jq
      yq-go
      ripgrep
      xmlstarlet
      iterm2
      eza
      tmux
      nnn
      fzf
      unzip
      iproute2mac
      gh
      jfrog-cli
      postgresql
      slack
      inetutils
      meslo-lgs-nf
      lsyncd
      visualvm
      uv
      nodejs
      linode-cli
      dynamodb-local
      graphviz
      cilium-cli
      pre-commit
      git-filter-repo
      bat
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
        cat = "bat --paging=never";

        k = "kubectl";
        kctx = "kubectx";
        kns = "kubens";

        tf = "terraform";

        ls = "eza --all --icons=always --git-repos";
        ll = "ls -la";

        nix-rebuild = "sudo darwin-rebuild switch --flake .";

        code = "open -a 'Visual Studio Code'";
        idea = "open -a 'IntelliJ IDEA'";

        flushdns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
        fixcaps = "hidutil property --set '{\"CapsLockDelayOverride\":10}'";
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