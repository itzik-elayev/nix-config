{ pkgs, pkgs-helm3, username, ... }:
let
  # Single source of engineering preferences in this repo, linked into every
  # agent's global-instructions path.
  agentInstructions = ./configs/coding-instructions.md;

  nixConfigDir = "~/Desktop/nix-config";

  yamlLanguageServer = "${pkgs.yaml-language-server}/bin/yaml-language-server";
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
      tmux
      nnn
      fzf
      unzip
      iproute2mac
      inetutils
      lsyncd
      stu
      s5cmd
      csvlens

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

        # Only redirect fresh terminals; editors spawn shells already in the project dir.
        if status is-login; and test "$PWD" = "$HOME"
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

        nix-rebuild = "sudo darwin-rebuild switch --flake ${nixConfigDir}";
        nix-build-system = "nix build ${nixConfigDir}#darwinConfigurations.(scutil --get LocalHostName).system --out-link ${nixConfigDir}/.nix-build/result";

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

    zed-editor = {
      enable = true;
      # Zed.app is installed via the homebrew cask; this only manages settings.
      # Extensions are declared here but downloaded by Zed from its registry.
      package = null;
      # Go/Python/JS/TS/JSON/YAML/Markdown have built-in language support; these
      # cover the rest of the stack (LSPs are downloaded by Zed per extension).
      extensions = [
        "terraform"
        "helm"
        "k8s-crd-lsp"
        "kubernetes-snippets"
        "dockerfile"
        "docker-compose"
        "nix"
        "toml"
        "sql"
        "basher"
        "make"
        "github-actions"
        "git-firefly"
      ];
      userSettings = {
        auto_update = false;

        buffer_font_family = "MesloLGS NF";
        ui_font_family = "MesloLGS NF";
        buffer_font_fallbacks = ["Menlo" "Monaco" "Courier New" "monospace"];

        icon_theme = "Zed (Default)";
        theme = {
          mode = "dark";
          light = "One Light";
          dark = "Ayu Dark";
        };

        git.inline_blame.enabled = true;
        agent.dock = "right";

        use_system_window_tabs = true;
        preview_tabs.enabled = false;
        minimap.show = "always";
        project_panel.auto_reveal_entries = false;
        session.trust_all_worktrees = true;
        terminal.working_directory = "current_project_directory";
        lsp_results_location = "picker";

        # The Nix extension starts both nil and nixd; nil alone covers this setup.
        languages.Nix.language_servers = ["nil" "!nixd"];

        # Chart templates share the .yaml extension with plain YAML; route them
        # to helm-ls so `{{ }}` isn't parsed as invalid YAML.
        file_types.Helm = [
          "**/templates/**/*.tpl"
          "**/templates/**/*.yaml"
          "**/templates/**/*.yml"
          "**/helmfile.d/**/*.yaml"
          "**/helmfile.d/**/*.yml"
          "**/values*.yaml"
          "**/values*.yml"
        ];

        agent_servers = {
          cursor.type = "registry";
          "claude-acp".type = "registry";
        };

        # Prefer nix-provided servers over Zed downloads. A `binary.path` override
        # drops the extension's default launch args, so servers needing them set `arguments`.
        lsp = {
          "gopls".binary.path = "${pkgs.gopls}/bin/gopls";
          "terraform-ls".binary = {
            path = "${pkgs.terraform-ls}/bin/terraform-ls";
            arguments = ["serve"];
          };
          "nil".binary.path = "${pkgs.nil}/bin/nil";
          "helm" = {
            binary = {
              path = "${pkgs.helm-ls}/bin/helm_ls";
              arguments = ["serve"];
            };
            settings.yamlls.path = yamlLanguageServer;
          };
          "yaml-language-server" = {
            binary = {
              path = yamlLanguageServer;
              arguments = ["--stdio"];
            };
            # Schema-based completion/validation for k8s manifests and CI YAML.
            settings.yaml.schemaStore.enable = true;
          };
        };
      };
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
