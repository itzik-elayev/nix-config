{ pkgs, username, ... }: {
  home = {
    username = username;

    stateVersion = "23.11";

    packages = with pkgs; [
      # Languages & runtimes
      go
      python3
      python3Packages.pip
      uv
      nodejs
      flutter

      # Go tooling
      golangci-lint
      go-task

      # Cloud providers
      awscli2
      saml2aws
      amazon-ecr-credential-helper
      ssm-session-manager-plugin
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      azure-cli
      linode-cli

      # Infrastructure
      terraform
      terraform-ls
      tflint
      packer
      consul
      vault
      vals

      # Containers
      docker
      skopeo
      dive

      # Security & scanning
      trivy
      snyk

      # Kubernetes
      kubectl
      kubecolor
      kubectl-node-shell
      kubectl-neat
      kubectl-validate
      kubernetes-helm
      helm-docs
      k9s
      k3d
      kind
      kubectx
      ctlptl
      ocm
      crc
      argocd
      tilt
      cilium-cli

      # Data & formats
      jq
      yq-go
      xmlstarlet
      postgresql
      dynamodb-local
      graphviz

      # CLI tools
      ripgrep
      eza
      tmux
      nnn
      fzf
      unzip
      iproute2mac
      inetutils
      lsyncd

      # Git
      gh
      pre-commit
      git-filter-repo

      # Dev tools
      jfrog-cli
      visualvm

      # AI
      claude-code
      claude-monitor
      codex

      # Apps
      iterm2
      slack

      # Fonts
      meslo-lgs-nf

      # Fun
      cmatrix

      # LSP servers
      yaml-language-server
    ];

    sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
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
    home-manager.enable = true;

    fish = {
      enable = true;

      interactiveShellInit = ''
        bind \e\x7F 'backward-kill-word'

        if status is-login; and test "$TERM_PROGRAM" != "vscode"
          cd ~/Desktop
        end
      '';

      shellAliases = {
        cat = "bat --paging=never";

        kubectl = "kubecolor";
        k = "kubectl";
        kctx = "kubectx";
        kns = "kubens";

        tf = "terraform";

        ls = "eza --all --icons=always --git-repos";
        ll = "ls -la";

        nix-rebuild = "sudo darwin-rebuild switch --flake ~/Desktop/nix-config";

        code = "open -a 'Visual Studio Code'";
        idea = "open -a 'IntelliJ IDEA'";

        flushdns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
        fixcaps = "hidutil property --set '{\"CapsLockDelayOverride\":10}'";
      };
    };

    bat = {
      enable = true;
      config.theme = "Dracula";
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withRuby = false;
      withPython3 = false;
      initLua = builtins.readFile ./configs/nvim/init.lua;
      plugins = with pkgs.vimPlugins; [
        nightfox-nvim
        vim-airline
        vim-surround
        vim-commentary
        vim-fugitive
        vim-gitgutter
        fzf-vim
        vim-yaml
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
      ];
    };

    git = {
      enable = true;

      settings = {
        user.name = "Itzhak Alayev";
        user.email = "startukk@gmail.com";
        push.autoSetupRemote = true;
        pull.rebase = false;
        color.ui = "auto";
      };
    };

    vscode = {
      enable = true;
      # VS Code.app itself is installed via the homebrew cask; this only manages settings.json.
      package = null;

      profiles.default.userSettings = {
        "claudeCode.preferredLocation" = "panel";
        "geminicodeassist.displayInlineContextHint" = false;
        "terminal.integrated.mouseWheelScrollSensitivity" = 3;
        "terminal.integrated.gpuAcceleration" = "off";
        "window.nativeTabs" = true;
        "window.zoomLevel" = 2;
        "editor.fontFamily" = "'MesloLGS NF', Menlo, Monaco, 'Courier New', monospace";

        "terminal.integrated.defaultProfile.osx" = "fish";
        "terminal.integrated.profiles.osx" = {
          fish = {
            path = "${pkgs.fish}/bin/fish";
          };
        };
      };

      profiles.default.keybindings = [
        {
          key = "shift+enter";
          command = "workbench.action.terminal.sendSequence";
          when = "terminalFocus";
          args = {
            text = "\r";
          };
        }
      ];
    };
  };
}
