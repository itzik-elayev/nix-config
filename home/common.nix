{ pkgs, pkgs-helm3, username, ... }:
let
  # Single source of engineering preferences in this repo, linked into every
  # agent's global-instructions path.
  agentInstructions = ./configs/coding-instructions.md;
in
{
  home = {
    username = username;

    stateVersion = "23.11";

    packages = with pkgs; [
      # Languages & runtimes
      go
      python3
      python3Packages.pip
      uv
      nodejs # also provides the `corepack` command
      pnpm
      bun
      maven
      flutter

      # Go tooling
      golangci-lint
      go-task
      gopls

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
      vals
      cloudflared

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
      pkgs-helm3.kubernetes-helm
      helm-docs
      fluxcd
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
      (callPackage ./pkgs/pgtui.nix {})
      dynamodb-local
      graphviz

      # CLI tools
      ripgrep
      eza
      nnn
      fzf
      sesh
      unzip
      iproute2mac
      inetutils
      lsyncd
      stu
      s5cmd
      csvlens

      # Editor (config managed imperatively via a nvim distribution, not nix)
      neovim
      fd

      # nvim LSP/formatters/linters — mason is disabled, tools come from PATH.
      # (gopls, golangci-lint, terraform-ls, nil, yaml-language-server, tflint,
      # nixfmt already provided above / in systemPackages.)
      tree-sitter
      gofumpt
      delve
      pyright
      ruff
      marksman
      hadolint
      shfmt
      stylua
      prettierd
      dockerfile-language-server
      vscode-langservers-extracted
      bash-language-server
      markdownlint-cli2

      # Git
      gh
      pre-commit
      git-filter-repo
      lazygit

      # Dev tools
      jfrog-cli
      visualvm

      # AI
      claude-code
      claude-monitor
      codex
      opencode
      opencode-claude-auth

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
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    sessionPath = [
      "$HOME/go/bin"
    ];
  };

  xdg = {
    enable = true;

    configFile = {
      "karabiner/karabiner.json" = {
        source = ./configs/karabiner/karabiner.json;
        force = true;
      };

      "opencode/AGENTS.md".source = agentInstructions;

      # recursive = per-file symlinks so the dir stays writable for lazy.nvim's
      # runtime plugin state and lazy-lock.json.
      "nvim" = {
        source = ./configs/nvim;
        recursive = true;
      };
    };

    dataFile = {
      "helm/plugins/helm-cm-push".source = "${pkgs-helm3.kubernetes-helmPlugins.helm-cm-push}/helm-cm-push";
    };
  };

  home.file = {
    ".claude/CLAUDE.md".source = agentInstructions;
    ".codex/AGENTS.md".source = agentInstructions;
    ".cursor/rules/personal.mdc".source = agentInstructions;
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    fish = {
      enable = true;

      interactiveShellInit = ''
        bind \e\x7F 'backward-kill-word'
        bind \e\x08 'backward-kill-word'

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

        vim = "nvim";
        vi = "nvim";

        code = "open -a 'Visual Studio Code'";
        idea = "open -a 'IntelliJ IDEA'";

        # The macOS GUI app bundles the CLI (same binary, runs in CLI mode from
        # a terminal) and it's the one that talks to the GUI app's daemon.
        tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";

        flushdns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
        fixcaps = "hidutil property --set '{\"CapsLockDelayOverride\":10}'";
      };

      functions = {
        kctx-rm = ''
          set -l ctx $argv[1]
          set -l cluster (kubectl config view -o jsonpath="{.contexts[?(@.name==\"$ctx\")].context.cluster}")
          set -l user (kubectl config view -o jsonpath="{.contexts[?(@.name==\"$ctx\")].context.user}")

          test -z "$cluster" && echo "no such context: $ctx" && return 1

          kubectl config delete-context $ctx
          kubectl config delete-cluster $cluster
          kubectl config delete-user $user
        '';
      };
    };

    bat = {
      enable = true;
      config.theme = "Dracula";
    };

    k9s = {
      enable = true;
      settings.k9s.ui.headless = true;
    };

    zoxide.enable = true;

    tmux = {
      enable = true;
      mouse = true;
      baseIndex = 1;
      keyMode = "vi";
      terminal = "tmux-256color";
      escapeTime = 10;
      extraConfig = ''
        set -ga terminal-overrides ",*256col*:Tc"

        # prefix+o: fuzzy project switcher; -d hides a dir when a session for it
        # already exists (no folder+window duplicate)
        bind-key o display-popup -E -w 60% -h 60% "sesh connect \"$(sesh list -d --icons | fzf --ansi --no-sort --prompt '⚡ ')\""
      '';
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

      # Curated subset only; other manually-installed extensions (e.g. from an
      # onboarding script) stay unmanaged.
      profiles.default.extensions = with pkgs.vscode-extensions; [
        hashicorp.terraform
        tim-koehler.helm-intellisense
        golang.go
      ];

      profiles.default.userSettings = {
        "claudeCode.preferredLocation" = "terminal";
        "geminicodeassist.displayInlineContextHint" = false;
        "terminal.integrated.mouseWheelScrollSensitivity" = 3;
        "terminal.integrated.gpuAcceleration" = "off";
        "window.nativeTabs" = true;
        "workbench.editor.enablePreview" = false;
        "window.zoomLevel" = 1;
        "editor.fontFamily" = "'MesloLGS NF', Menlo, Monaco, 'Courier New', monospace";

        # Widen explorer tree indentation (default 8) so nested folder levels
        # are easier to tell apart, and always show the indent guide lines.
        "workbench.tree.indent" = 20;
        "workbench.tree.renderIndentGuides" = "always";

        # Don't auto-reveal (jump to) the active file in the explorer on
        # tab switch/close.
        "explorer.autoReveal" = false;

        # Use the extension's bundled, version-matched terraform-ls; overriding
        # to nix's older build broke go-to-definition/references.
        "terraform.languageServer.enable" = true;
        "terraform.codelens.referenceCount" = true;
        "[terraform]" = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "hashicorp.terraform";
        };
        "[terraform-vars]" = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "hashicorp.terraform";
        };

        "go.useLanguageServer" = true;
        "go.alternateTools" = {
          "gopls" = "${pkgs.gopls}/bin/gopls";
        };
        "[go]" = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "golang.go";
        };

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

    opencode = {
      enable = true;
      settings = {
        plugin = ["opencode-claude-auth"];
      };
    };
  };
}
